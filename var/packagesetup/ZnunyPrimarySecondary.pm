# --
# Copyright (C) 2001-2021 OTRS AG, https://otrs.com/
# Copyright (C) 2021 Znuny GmbH, https://znuny.org/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package var::packagesetup::ZnunyPrimarySecondary;

use strict;
use warnings;
use utf8;

use Kernel::System::VariableCheck qw(:all);

our @ObjectDependencies = (
    'Kernel::Config',
    'Kernel::System::Cache',
    'Kernel::System::DB',
    'Kernel::System::DynamicField',
    'Kernel::System::DynamicFieldValue',
    'Kernel::System::Log',
    'Kernel::System::SysConfig',
    'Kernel::System::SysConfig::Migration',
    'Kernel::System::ZnunyHelper',
);

=head1 NAME

var::packagesetup::ZnunyPrimarySecondary - code to execute during package installation

=head1 SYNOPSIS

Functions for installing the ZnunyPrimarySecondary package.

=head1 PUBLIC INTERFACE

=over 4

=cut

=item new()

create an object. Do not use it directly, instead use:

    use Kernel::System::ObjectManager;
    local $Kernel::OM = Kernel::System::ObjectManager->new();
    my $CodeObject = $Kernel::OM->Get('var::packagesetup::ZnunyPrimarySecondary');

=cut

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    # Force a reload of ZZZAuto.pm to get the fresh configuration values.
    for my $Module ( sort keys %INC ) {
        if ( $Module =~ m/ZZZAA?uto\.pm$/ ) {
            delete $INC{$Module};
        }
    }

    $Kernel::OM->ObjectsDiscard(
        Objects => ['Kernel::Config'],
    );

    # get dynamic fields list
    $Self->{DynamicFieldsList} = $Kernel::OM->Get('Kernel::System::DynamicField')->DynamicFieldListGet(
        Valid      => 0,
        ObjectType => ['Ticket'],
    );

    if ( !IsArrayRefWithData( $Self->{DynamicFieldsList} ) ) {
        $Self->{DynamicFieldsList} = [];
    }

    # create a dynamic field lookup table (by name)
    DYNAMICFIELD:
    for my $DynamicField ( @{ $Self->{DynamicFieldsList} } ) {
        next DYNAMICFIELD if !$DynamicField;
        next DYNAMICFIELD if !IsHashRefWithData($DynamicField);
        next DYNAMICFIELD if !$DynamicField->{Name};
        $Self->{DynamicFieldLookup}->{ $DynamicField->{Name} } = $DynamicField;
    }

    return $Self;
}

=item CodeInstall()

run the code install part

    my $Result = $CodeObject->CodeInstall();

=cut

sub CodeInstall {
    my ( $Self, %Param ) = @_;

    #     my $MasterSlaveDynamicFieldID = $Self->_CheckMasterSlaveData();

    my $ConfigObject       = $Kernel::OM->Get('Kernel::Config');
    my $DynamicFieldObject = $Kernel::OM->Get('Kernel::System::DynamicField');

    my $MasterSlaveDynamicField = $ConfigObject->Get('MasterSlave::DynamicField') || 'MasterSlave';
    my $OldDynamicField         = $DynamicFieldObject->DynamicFieldGet(
        Name => $MasterSlaveDynamicField,
    );

    if ( IsHashRefWithData($OldDynamicField) ) {

        # Migrate DynamicFieldConfig.
        $Self->_MigrateToPrimarySecondary(%Param);

        # Migrate SysConfig
        $Self->_MigratePrimarySecondarySysConfigSettings(%Param);
    }
    else {
        # Create DynamicFields
        $Self->_SetDynamicFields(%Param);
    }

    # Set dashboard config if needed
    $Self->_SetDashboardConfig(%Param);

    return 1;
}

=item CodeReinstall()

run the code reinstall part

    my $Result = $CodeObject->CodeReinstall();

=cut

sub CodeReinstall {
    my ( $Self, %Param ) = @_;

    return if !$Self->CodeInstall();

    return 1;
}

=item CodeUpgrade()

run the code upgrade part

    my $Result = $CodeObject->CodeUpgrade();

=cut

sub CodeUpgrade {
    my ( $Self, %Param ) = @_;

    return if !$Self->CodeInstall();

    return 1;
}

=item CodeUninstall()

run the code uninstall part

    my $Result = $CodeObject->CodeUninstall();

=cut

sub CodeUninstall {
    my ( $Self, %Param ) = @_;

    $Self->_RemoveDynamicFields();

    return 1;
}

sub _SetDynamicFields {
    my ( $Self, %Param ) = @_;

    # get config object
    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');

    # get dynamic field names from SysConfig
    my $PrimarySecondaryDynamicField = $ConfigObject->Get('PrimarySecondary::DynamicField') || 'PrimarySecondary';

    # set attributes of new dynamic fields
    my %NewDynamicFields = (
        $PrimarySecondaryDynamicField => {
            Name       => $PrimarySecondaryDynamicField,
            Label      => 'Primary Ticket',
            FieldType  => 'PrimarySecondary',
            ObjectType => 'Ticket',
            Config     => {
                DefaultValue       => '',
                PossibleNone       => 1,
                TranslatableValues => 1,
            },
            InternalField => 1,
        },
    );

    # set MaxFieldOrder (needed for adding new dynamic fields)
    my $MaxFieldOrder = 0;
    if ( !IsArrayRefWithData( $Self->{DynamicFieldsList} ) ) {
        $MaxFieldOrder = 1;
    }
    else {
        DYNAMICFIELD:
        for my $DynamicFieldConfig ( @{ $Self->{DynamicFieldsList} } ) {
            if ( int $DynamicFieldConfig->{FieldOrder} > int $MaxFieldOrder ) {
                $MaxFieldOrder = $DynamicFieldConfig->{FieldOrder};
            }
        }
    }

    # get dynamic field object
    my $DynamicFieldObject = $Kernel::OM->Get('Kernel::System::DynamicField');

    for my $NewFieldName ( sort keys %NewDynamicFields ) {

        # check if dynamic field already exists
        if ( IsHashRefWithData( $Self->{DynamicFieldLookup}->{$NewFieldName} ) ) {

            # get the dynamic field configuration
            my $DynamicFieldConfig = $Self->{DynamicFieldLookup}->{$NewFieldName};

            my $Update;

            # update field configuration if it was other than PrimarySecondary (e.g. Dropdown)
            if ( $DynamicFieldConfig->{FieldType} ne 'PrimarySecondary' ) {
                my $ID = $DynamicFieldConfig->{ID};
                %{$DynamicFieldConfig} = ( %{$DynamicFieldConfig}, %{ $NewDynamicFields{$NewFieldName} } );
                $Update = 1;
            }

            # if dynamic field exists make sure is valid
            if ( $DynamicFieldConfig->{ValidID} ne '1' ) {
                $Update = 1;
            }

            if ($Update) {

                my $Success = $DynamicFieldObject->DynamicFieldUpdate(
                    %{$DynamicFieldConfig},
                    ValidID => 1,
                    Reorder => 0,
                    UserID  => 1,
                );

                if ( !$Success ) {
                    $Kernel::OM->Get('Kernel::System::Log')->Log(
                        Priority => 'error',
                        Message  => "Could not set dynamic field '$NewFieldName' to valid!",
                    );
                }
            }
            if ( $DynamicFieldConfig->{InternalField} ne '1' ) {

                # update InternalField value manually since API does not support
                # internal_field update
                my $Success = $Kernel::OM->Get('Kernel::System::DB')->Do(
                    SQL => '
                        UPDATE dynamic_field
                        SET internal_field = 1
                        WHERE id = ?',
                    Bind => [ \$DynamicFieldConfig->{ID} ],
                );
                if ( !$Success ) {
                    $Kernel::OM->Get('Kernel::System::Log')->Log(
                        Priority => 'error',
                        Message  => "Could not set dynamic field '$NewFieldName' as internal!",
                    );
                }

                # clean dynamic field cache
                $Kernel::OM->Get('Kernel::System::Cache')->CleanUp(
                    Type => 'DynamicField',
                );
            }
        }

        # otherwise create it
        else {
            $MaxFieldOrder++;
            my $ID = $DynamicFieldObject->DynamicFieldAdd(
                %{ $NewDynamicFields{$NewFieldName} },
                FieldOrder => $MaxFieldOrder,
                ValidID    => 1,
                UserID     => 1,
            );

            if ( !$ID ) {
                $Kernel::OM->Get('Kernel::System::Log')->Log(
                    Priority => 'error',
                    Message  => "Could not add dynamic field '$NewFieldName'!",
                );
            }
        }
    }

    # enable dynamic field for ticket zoom
    # get old configuration
    my $WindowConfig  = $ConfigObject->Get('Ticket::Frontend::AgentTicketZoom');
    my %DynamicFields = %{ $WindowConfig->{DynamicField} || {} };

    $DynamicFields{$PrimarySecondaryDynamicField} =
        defined $DynamicFields{$PrimarySecondaryDynamicField}
        ? $DynamicFields{$PrimarySecondaryDynamicField}
        : 1;

    my $SysConfigObject = $Kernel::OM->Get('Kernel::System::SysConfig');
    return 0 if !$SysConfigObject->SettingsSet(
        UserID   => 1,
        Comments => 'ZnunyPrimarySecondary - deploy AgentTicketZoom dynamic fields',
        Settings => [
            {
                Name           => 'Ticket::Frontend::AgentTicketZoom###DynamicField',
                EffectiveValue => \%DynamicFields,
                IsValid        => 1,
            },
        ],
    );

    return 1;
}

sub _RemoveDynamicFields {
    my ( $Self, %Param ) = @_;

    # get config object
    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');

    # get dynamic field names from SysConfig
    my $PrimarySecondaryDynamicField = $ConfigObject->Get('PrimarySecondary::DynamicField') || 'PrimarySecondary';

    # check if dynamic field already exists
    if ( IsHashRefWithData( $Self->{DynamicFieldLookup}->{$PrimarySecondaryDynamicField} ) ) {

        # get the field ID
        my $DynamicFieldID = $Self->{DynamicFieldLookup}->{$PrimarySecondaryDynamicField}->{ID};

        # delete all field values
        my $ValuesDeleteSuccess = $Kernel::OM->Get('Kernel::System::DynamicFieldValue')->AllValuesDelete(
            FieldID => $DynamicFieldID,
            UserID  => 1,
        );

        if ($ValuesDeleteSuccess) {

            # delete field
            my $Success = $Kernel::OM->Get('Kernel::System::DynamicField')->DynamicFieldDelete(
                ID      => $DynamicFieldID,
                UserID  => 1,
                Reorder => 1,
            );

            if ( !$Success ) {
                $Kernel::OM->Get('Kernel::System::Log')->Log(
                    Priority => 'error',
                    Message  => "Could not delete dynamic field '$PrimarySecondaryDynamicField'!",
                );
            }
        }
        else {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Could not delete values for dynamic field '$PrimarySecondaryDynamicField'!",
            );
        }
    }

    my $SysConfigObject = $Kernel::OM->Get('Kernel::System::SysConfig');

    # disable SysConfig settings
    return if !$SysConfigObject->SettingsSet(
        UserID   => 1,
        Comments => 'ZnunyPrimarySecondary - # disable SysConfig settings.',
        Settings => [
            {
                Name           => 'DynamicFields::Driver###PrimarySecondary',
                EffectiveValue => {
                    DisplayName  => 'Primary / Secondary',
                    Module       => 'Kernel::System::DynamicField::Driver::PrimarySecondary',
                    ConfigDialog => 'AdminDynamicFieldPrimarySecondary',
                    DisabledAdd  => 1,
                },
                IsValid => 0,
            },
            {
                Name           => 'PreApplicationModule###AgentPrePrimarySecondary',
                EffectiveValue => 'Kernel::Modules::AgentPrePrimarySecondary',
                IsValid        => 0,
            },
        ],
    );

    # discard config object and dynamic field backend to prevent error messages due missing driver
    $Kernel::OM->ObjectsDiscard(
        Objects => [ 'Kernel::Config', 'Kernel::System::DynamicField::Backend' ],
    );

    # disable dynamic field for ticket zoom
    # get old configuration
    my $WindowConfig  = $ConfigObject->Get('Ticket::Frontend::AgentTicketZoom');
    my %DynamicFields = %{ $WindowConfig->{DynamicField} || {} };

    if ( defined $DynamicFields{$PrimarySecondaryDynamicField} ) {
        $DynamicFields{$PrimarySecondaryDynamicField} = 0;
    }

    return if !$SysConfigObject->SettingsSet(
        UserID   => 1,
        Comments => 'ZnunyPrimarySecondary - deploy dynamic fields.',
        Settings => [
            {
                Name           => 'Ticket::Frontend::AgentTicketZoom###DynamicField',
                EffectiveValue => \%DynamicFields,
                IsValid        => 1,
            },
        ],
    );

    return 1;
}

sub _SetDashboardConfig {
    my ( $Self, %Param ) = @_;

    # get dynamic field names from SysConfig
    my $PrimarySecondaryDynamicField
        = $Kernel::OM->Get('Kernel::Config')->Get('PrimarySecondary::DynamicField') || 'PrimarySecondary';

    # attributes common for both Primary and Secondary widgets
    my %CommonConfig = (
        Module        => 'Kernel::Output::HTML::DashboardTicketGeneric',
        Filter        => 'All',
        Time          => 'Age',
        Limit         => 10,
        Permission    => 'rw',
        Block         => 'ContentLarge',
        Group         => '',
        Default       => 1,
        CacheTTLLocal => 0.5,
    );

    # attributes for Primary widget
    my %PrimaryConfig = (
        Title       => 'Primary Tickets',
        Description => 'All primary tickets',
        Attributes  => 'DynamicField_' . $PrimarySecondaryDynamicField . '_Equals=Primary;',
    );

    # attributes for Secondary widget
    my %SecondaryConfig = (
        Title       => 'Secondary Tickets',
        Description => 'All secondary tickets',
        Attributes  => 'DynamicField_' . $PrimarySecondaryDynamicField . '_Like=Secondary*;',
    );

    # get SysConfig object
    my $SysConfigObject = $Kernel::OM->Get('Kernel::System::SysConfig');

    # write configurations
    return if !$SysConfigObject->SettingsSet(
        UserID   => 1,
        Comments => 'ZnunyPrimarySecondary - deploy dynamic fields for dashboard.',
        Settings => [
            {
                Name           => 'DashboardBackend###0900-TicketPrimary',
                EffectiveValue => {
                    %CommonConfig,
                    %PrimaryConfig,
                },
                IsValid => 1,
            },
            {
                Name           => 'DashboardBackend###0910-TicketSecondary',
                EffectiveValue => {
                    %CommonConfig,
                    %SecondaryConfig,
                },
                IsValid => 1,
            },
        ],
    );

    return 1;
}

sub _MigratePrimarySecondarySysConfigSettings {
    my ( $Self, %Param ) = @_;

    my $ConfigObject             = $Kernel::OM->Get('Kernel::Config');
    my $SysConfigObject          = $Kernel::OM->Get('Kernel::System::SysConfig');
    my $SysConfigMigrationObject = $Kernel::OM->Get('Kernel::System::SysConfig::Migration');
    my $ZnunyHelperObject        = $Kernel::OM->Get('Kernel::System::ZnunyHelper');
    my $LogObject                = $Kernel::OM->Get('Kernel::System::Log');

    my $UserID = 1;

    my %RenamedSysConfigOptions = (
        'MasterSlave::KeepParentChildAfterUpdate' => ['PrimarySecondary::KeepParentChildAfterUpdate'],
        'ReplaceCustomerRealNameOnSlaveArticleCommunicationChannels' =>
            ['ReplaceCustomerRealNameOnSecondaryArticleCommunicationChannels'],
        'DashboardBackend###0910-TicketSlave'  => ['DashboardBackend###0910-TicketSecondary'],
        'DashboardBackend###0900-TicketMaster' => ['DashboardBackend###0900-TicketPrimary'],
        'Ticket::Frontend::AgentTicketMasterSlave###MasterSlaveMandatory' =>
            ['Ticket::Frontend::AgentTicketPrimarySecondary###PrimarySecondaryMandatory'],
        'Ticket::Frontend::AgentTicketMasterSlave###HistoryComment' =>
            ['Ticket::Frontend::AgentTicketPrimarySecondary###HistoryComment'],
        'Ticket::Frontend::AgentTicketMasterSlave###HistoryType' =>
            ['Ticket::Frontend::AgentTicketPrimarySecondary###HistoryType'],
        'Ticket::Frontend::AgentTicketMasterSlave###Title' => ['Ticket::Frontend::AgentTicketPrimarySecondary###Title'],
        'Ticket::Frontend::AgentTicketMasterSlave###PriorityDefault' =>
            ['Ticket::Frontend::AgentTicketPrimarySecondary###PriorityDefault'],
        'Ticket::Frontend::AgentTicketMasterSlave###Priority' =>
            ['Ticket::Frontend::AgentTicketPrimarySecondary###Priority'],
        'Ticket::Frontend::AgentTicketMasterSlave###IsVisibleForCustomerDefault' =>
            ['Ticket::Frontend::AgentTicketPrimarySecondary###IsVisibleForCustomerDefault'],
        'Ticket::Frontend::AgentTicketMasterSlave###InformAgent' =>
            ['Ticket::Frontend::AgentTicketPrimarySecondary###InformAgent'],
        'Ticket::Frontend::AgentTicketMasterSlave###InvolvedAgent' =>
            ['Ticket::Frontend::AgentTicketPrimarySecondary###InvolvedAgent'],
        'Ticket::Frontend::AgentTicketMasterSlave###RichTextHeight' =>
            ['Ticket::Frontend::AgentTicketPrimarySecondary###RichTextHeight'],
        'Ticket::Frontend::AgentTicketMasterSlave###RichTextWidth' =>
            ['Ticket::Frontend::AgentTicketPrimarySecondary###RichTextWidth'],
        'Ticket::Frontend::AgentTicketMasterSlave###Body' => ['Ticket::Frontend::AgentTicketPrimarySecondary###Body'],
        'Ticket::Frontend::AgentTicketMasterSlave###Subject' =>
            ['Ticket::Frontend::AgentTicketPrimarySecondary###Subject'],
        'Ticket::Frontend::AgentTicketMasterSlave###NoteMandatory' =>
            ['Ticket::Frontend::AgentTicketPrimarySecondary###NoteMandatory'],
        'Ticket::Frontend::AgentTicketMasterSlave###Note' => ['Ticket::Frontend::AgentTicketPrimarySecondary###Note'],
        'Ticket::Frontend::AgentTicketMasterSlave###StateDefault' =>
            ['Ticket::Frontend::AgentTicketPrimarySecondary###StateDefault'],
        'Ticket::Frontend::AgentTicketMasterSlave###StateType' =>
            ['Ticket::Frontend::AgentTicketPrimarySecondary###StateType'],
        'Ticket::Frontend::AgentTicketMasterSlave###State' => ['Ticket::Frontend::AgentTicketPrimarySecondary###State'],
        'Ticket::Frontend::AgentTicketMasterSlave###ResponsibleMandatory' =>
            ['Ticket::Frontend::AgentTicketPrimarySecondary###ResponsibleMandatory'],
        'Ticket::Frontend::AgentTicketMasterSlave###Responsible' =>
            ['Ticket::Frontend::AgentTicketPrimarySecondary###Responsible'],
        'Ticket::Frontend::AgentTicketMasterSlave###OwnerMandatory' =>
            ['Ticket::Frontend::AgentTicketPrimarySecondary###OwnerMandatory'],
        'Ticket::Frontend::AgentTicketMasterSlave###Owner' => ['Ticket::Frontend::AgentTicketPrimarySecondary###Owner'],
        'Ticket::Frontend::AgentTicketMasterSlave###Service' =>
            ['Ticket::Frontend::AgentTicketPrimarySecondary###Service'],
        'Ticket::Frontend::AgentTicketMasterSlave###TicketType' =>
            ['Ticket::Frontend::AgentTicketPrimarySecondary###TicketType'],
        'Ticket::Frontend::AgentTicketMasterSlave###RequiredLock' =>
            ['Ticket::Frontend::AgentTicketPrimarySecondary###RequiredLock'],
        'Ticket::Frontend::AgentTicketMasterSlave###Permission' =>
            ['Ticket::Frontend::AgentTicketPrimarySecondary###Permission'],
        'MasterSlave::KeepParentChildAfterUnset' => ['PrimarySecondary::KeepParentChildAfterUnset'],
        'MasterSlave::ForwardSlave'              => ['PrimarySecondary::ForwardSecondary'],
        'MasterSlave::AdvancedEnabled'           => ['PrimarySecondary::AdvancedEnabled'],
        'MasterSlave::UnsetMasterSlave'          => ['PrimarySecondary::UnsetPrimarySecondary'],
        'MasterSlave::UpdateMasterSlave'         => ['PrimarySecondary::UpdatePrimarySecondary'],
        'MasterSlave::FollowUpdatedMaster'       => ['PrimarySecondary::FollowUpdatedPrimary'],
    );

    ORIGINALSYSCONFIGOPTIONNAME:
    for my $OriginalSysConfigOptionName ( sort keys %RenamedSysConfigOptions ) {

        # Fetch original SysConfig option value.
        my ( $OriginalSysConfigOptionBaseName, @OriginalSysConfigOptionHashKeys ) = split '###',
            $OriginalSysConfigOptionName;

        my $OriginalSysConfigOptionValue = $ConfigObject->Get($OriginalSysConfigOptionBaseName);
        next ORIGINALSYSCONFIGOPTIONNAME if !defined $OriginalSysConfigOptionValue;

        if (@OriginalSysConfigOptionHashKeys) {
            for my $OriginalSysConfigOptionHashKey (@OriginalSysConfigOptionHashKeys) {
                next ORIGINALSYSCONFIGOPTIONNAME if ref $OriginalSysConfigOptionValue ne 'HASH';
                next ORIGINALSYSCONFIGOPTIONNAME
                    if !exists $OriginalSysConfigOptionValue->{$OriginalSysConfigOptionHashKey};

                $OriginalSysConfigOptionValue = $OriginalSysConfigOptionValue->{$OriginalSysConfigOptionHashKey};
            }
        }
        next ORIGINALSYSCONFIGOPTIONNAME if !defined $OriginalSysConfigOptionValue;

        my $NewSysConfigOptionNames = $RenamedSysConfigOptions{$OriginalSysConfigOptionName};
        for my $NewSysConfigOptionName ( @{$NewSysConfigOptionNames} ) {
            my $SettingUpdated = $SysConfigObject->SettingsSet(
                Settings => [
                    {
                        Name           => $NewSysConfigOptionName,
                        IsValid        => 1,
                        EffectiveValue => $OriginalSysConfigOptionValue,
                    },
                ],
                UserID => $UserID,
            );

            next ORIGINALSYSCONFIGOPTIONNAME if $SettingUpdated;

            $LogObject->Log(
                Priority => 'error',
                Message =>
                    "Error: Unable to migrate value of SysConfig option $OriginalSysConfigOptionName to option $NewSysConfigOptionName",
            );
        }
    }

    $ZnunyHelperObject->_RebuildConfig();

    return 1;
}

sub _MigrateToPrimarySecondary {
    my ( $Self, %Param ) = @_;

    my $ConfigObject       = $Kernel::OM->Get('Kernel::Config');
    my $DynamicFieldObject = $Kernel::OM->Get('Kernel::System::DynamicField');
    my $DBObject           = $Kernel::OM->Get('Kernel::System::DB');

    # get dynamic field names from SysConfig
    my $MasterSlaveDynamicField = $ConfigObject->Get('MasterSlave::DynamicField') || 'MasterSlave';

    my $OldDynamicField = $DynamicFieldObject->DynamicFieldGet(
        Name => $MasterSlaveDynamicField,
    );
    return 0 if !IsHashRefWithData($OldDynamicField);

    # update the Label and FieldType of the dynamic field to PrimarySecondary
    return 0 if !$DynamicFieldObject->DynamicFieldUpdate(
        %{$OldDynamicField},
        ID         => $OldDynamicField->{ID},
        Name       => 'PrimarySecondary',
        Label      => 'Primary Ticket',
        FieldType  => 'PrimarySecondary',
        ObjectType => 'Ticket',
        Config     => {
            DefaultValue       => '',
            PossibleNone       => 1,
            TranslatableValues => 1,
        },
        InternalField => 1,
        ValidID       => 1,
        Reorder       => 0,
        UserID        => 1,
    );

    # update InternalField value manually since API does not support internal_field update
    my $Success = $DBObject->Do(
        SQL => '
            UPDATE dynamic_field
            SET internal_field = 1
            WHERE id = ?',
        Bind => [ \$OldDynamicField->{ID} ],
    );
    if ( !$Success ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => "Could not set dynamic field '$MasterSlaveDynamicField' as internal!",
        );
    }

    # clean dynamic field cache
    $Kernel::OM->Get('Kernel::System::Cache')->CleanUp(
        Type => 'DynamicField',
    );

    # activate the DynamicField in ticket details block
    my $KeyString       = "Ticket::Frontend::AgentTicketZoom";
    my $ExistingSetting = $ConfigObject->Get($KeyString) || {};
    my %ValuesToSet     = %{ $ExistingSetting->{DynamicField} || {} };
    $ValuesToSet{PrimarySecondary} = 1;

    return if !$Kernel::OM->Get('Kernel::System::SysConfig')->SettingsSet(
        UserID   => 1,
        Comments => 'Znuny-PrimarySecondary - deploy dynamic fields.',
        Settings => [
            {
                Name           => $KeyString . "###DynamicField",
                EffectiveValue => \%ValuesToSet,
                IsValid        => 1,
            },
        ],
    );

    return 1;
}

1;

=back

=head1 TERMS AND CONDITIONS

This software is part of the OTRS project (L<https://otrs.org/>).

This software comes with ABSOLUTELY NO WARRANTY. For details, see
the enclosed file COPYING for license information (GPL). If you
did not receive this file, see L<https://www.gnu.org/licenses/gpl-3.0.txt>.

=cut
