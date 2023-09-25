# --
# Copyright (C) 2001-2021 OTRS AG, https://otrs.com/
# Copyright (C) 2021 Znuny GmbH, https://znuny.org/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package Kernel::System::DynamicField::Driver::PrimarySecondary;

use strict;
use warnings;
use utf8;

use Kernel::System::VariableCheck qw(:all);

use parent qw(Kernel::System::DynamicField::Driver::BaseSelect);

our @ObjectDependencies = (
    'Kernel::Config',
    'Kernel::Language',
    'Kernel::Output::HTML::Layout',
    'Kernel::System::DynamicFieldValue',
    'Kernel::System::DynamicField',
    'Kernel::System::DynamicField::Backend',
    'Kernel::System::LinkObject',
    'Kernel::System::Log',
    'Kernel::System::Main',
    'Kernel::System::Ticket',
);

=head1 NAME

Kernel::System::DynamicField::Driver::PrimarySecondary

=head1 SYNOPSIS

DynamicFields PrimarySecondary Driver delegate

=head1 PUBLIC INTERFACE

This module implements the public interface of L<Kernel::System::DynamicField::Backend>.
Please look there for a detailed reference of the functions.

=head2 new()

usually, you want to create an instance of this
by using Kernel::System::DynamicField::Backend->new();

=cut

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    # set field behaviors
    $Self->{Behaviors} = {
        'IsACLReducible'               => 0,
        'IsNotificationEventCondition' => 1,
        'IsSortable'                   => 1,
        'IsFiltrable'                  => 1,
        'IsStatsCondition'             => 1,
        'IsCustomerInterfaceCapable'   => 0,
    };

    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');
    my $MainObject   = $Kernel::OM->Get('Kernel::System::Main');

    # get the Dynamic Field Backend custom extensions
    my $DynamicFieldDriverExtensions = $ConfigObject->Get('DynamicFields::Extension::Driver::PrimarySecondary');

    EXTENSION:
    for my $ExtensionKey ( sort keys %{$DynamicFieldDriverExtensions} ) {

        # skip invalid extensions
        next EXTENSION if !IsHashRefWithData( $DynamicFieldDriverExtensions->{$ExtensionKey} );

        # create a extension config shortcut
        my $Extension = $DynamicFieldDriverExtensions->{$ExtensionKey};

        # check if extension has a new module
        if ( $Extension->{Module} ) {

            # check if module can be loaded
            if (
                !$MainObject->RequireBaseClass( $Extension->{Module} )
                )
            {
                die "Can't load dynamic fields backend module"
                    . " $Extension->{Module}! $@";
            }
        }

        # check if extension contains more behaviors
        if ( IsHashRefWithData( $Extension->{Behaviors} ) ) {

            %{ $Self->{Behaviors} } = (
                %{ $Self->{Behaviors} },
                %{ $Extension->{Behaviors} }
            );
        }
    }

    return $Self;
}

sub ValueIsDifferent {
    my ( $Self, %Param ) = @_;

    # Special cases where the values are different but they should be reported as equals.
    return
        if !defined $Param{Value1}
        && (
        defined $Param{Value2}
        && (
            $Param{Value2} eq 'UnsetPrimary'
            || $Param{Value2} eq 'UnsetSecondary'
            || $Param{Value2} eq ''
        )
        );

    # Compare the results.
    return DataIsDifferent(
        Data1 => \$Param{Value1},
        Data2 => \$Param{Value2}
    );
}

sub ValueSet {
    my ( $Self, %Param ) = @_;

    my $LogObject               = $Kernel::OM->Get('Kernel::System::Log');
    my $DynamicFieldValueObject = $Kernel::OM->Get('Kernel::System::DynamicFieldValue');

    my $Success = $Self->_HandleLinks(
        FieldName  => $Param{DynamicFieldConfig}->{Name},
        FieldValue => $Param{Value},
        TicketID   => $Param{ObjectID},
        UserID     => $Param{UserID},
    );

    if ( !$Success ) {
        $LogObject->Log(
            Priority => 'error',
            Message  => "There was an error handling the links for primary/secondary, value could not be set",
        );

        return;
    }

    my $Value = $Param{Value} !~ /^(?:UnsetPrimary|UnsetSecondary)$/ ? $Param{Value} : '';

    $Success = $DynamicFieldValueObject->ValueSet(
        FieldID  => $Param{DynamicFieldConfig}->{ID},
        ObjectID => $Param{ObjectID},
        Value    => [
            {
                ValueText => $Value,
            },
        ],
        UserID => $Param{UserID},
    );

    return $Success;
}

sub EditFieldValueValidate {
    my ( $Self, %Param ) = @_;

    # get the field value from the http request
    my $Value = $Self->EditFieldValueGet(
        DynamicFieldConfig => $Param{DynamicFieldConfig},
        ParamObject        => $Param{ParamObject},

        # not necessary for this Driver but place it for consistency reasons
        ReturnValueStructure => 1,
    );

    my $ServerError;
    my $ErrorMessage;

    # perform necessary validations
    if ( $Param{Mandatory} && !$Value ) {
        return {
            ServerError => 1,
        };
    }
    else {

        my $PossibleValues;

        # use PossibleValuesFilter if sent
        if ( defined $Param{PossibleValuesFilter} ) {
            $PossibleValues = $Param{PossibleValuesFilter};
        }
        else {

            # get possible values list
            $PossibleValues = $Self->PossibleValuesGet(
                %Param,
            );
        }

        # validate if value is in possible values list (but let pass empty values)
        if ( $Value && !$PossibleValues->{$Value} ) {
            $ServerError  = 1;
            $ErrorMessage = 'The field content is invalid';
        }
    }

    # create resulting structure
    my $Result = {
        ServerError  => $ServerError,
        ErrorMessage => $ErrorMessage,
    };

    return $Result;
}

sub DisplayValueRender {
    my ( $Self, %Param ) = @_;

    # set HTMLOutput as default if not specified
    if ( !defined $Param{HTMLOutput} ) {
        $Param{HTMLOutput} = 1;
    }

    # get raw Value strings from field value
    my $Value = defined $Param{Value} ? $Param{Value} : '';

    # get real value
    if ( $Param{DynamicFieldConfig}->{Config}->{PossibleValues}->{$Value} ) {

        # get readable value
        $Value = $Param{DynamicFieldConfig}->{Config}->{PossibleValues}->{$Value};
    }

    if ( $Value =~ m{(Primary|Master)} ) {
        $Value = $Param{LayoutObject}->{LanguageObject}->Translate('Primary');
    }
    elsif ( $Value =~ m{(SecondaryOf|SlaveOf):(\d+)}msx ) {

        my $TicketNumber = $2;
        if ($TicketNumber) {
            my $ConfigObject      = $Kernel::OM->Get('Kernel::Config');
            my $TicketHook        = $ConfigObject->Get('Ticket::Hook');
            my $TicketHookDivider = $ConfigObject->Get('Ticket::HookDivider');
            $Value = $Param{LayoutObject}->{LanguageObject}->Translate(
                'Secondary of %s%s%s',
                $TicketHook,
                $TicketHookDivider,
                $TicketNumber,
            );
        }
    }

    # set title as value after update and before limit
    my $Title = $Value;

    # HTMLOutput transformations
    if ( $Param{HTMLOutput} ) {
        $Value = $Param{LayoutObject}->Ascii2Html(
            Text => $Value,
            Max  => $Param{ValueMaxChars} || '',
        );

        $Title = $Param{LayoutObject}->Ascii2Html(
            Text => $Title,
            Max  => $Param{TitleMaxChars} || '',
        );
    }
    else {
        if ( $Param{ValueMaxChars} && length($Value) > $Param{ValueMaxChars} ) {
            $Value = substr( $Value, 0, $Param{ValueMaxChars} ) . '...';
        }
        if ( $Param{TitleMaxChars} && length($Title) > $Param{TitleMaxChars} ) {
            $Title = substr( $Title, 0, $Param{TitleMaxChars} ) . '...';
        }
    }

    # set field link from config
    my $Link        = $Param{DynamicFieldConfig}->{Config}->{Link}        || '';
    my $LinkPreview = $Param{DynamicFieldConfig}->{Config}->{LinkPreview} || '';

    my $Data = {
        Value       => $Value,
        Title       => $Title,
        Link        => $Link,
        LinkPreview => $LinkPreview,
    };

    return $Data;
}

sub PossibleValuesGet {
    my ( $Self, %Param ) = @_;

    # to store the possible values
    my %PossibleValues = (
        '' => '-',
    );

    my $TicketObject = $Kernel::OM->Get('Kernel::System::Ticket');
    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');

    # find all current open primary secondary tickets and the legacy master slave tickets
    my @TicketIDs;
    my @PrimaryTickets = $TicketObject->TicketSearch(
        Result => 'ARRAY',

        # primary secondary dynamic field
        'DynamicField_' . $Param{DynamicFieldConfig}->{Name} => {
            Equals => 'Primary',
        },

        StateType  => 'Open',
        Limit      => 60,
        UserID     => $LayoutObject->{UserID},
        Permission => 'ro',
    );
    my @MasterTickets = $TicketObject->TicketSearch(
        Result => 'ARRAY',

        # primary secondary dynamic field
        'DynamicField_' . $Param{DynamicFieldConfig}->{Name} => {
            Equals => 'Master',
        },

        StateType  => 'Open',
        Limit      => 60,
        UserID     => $LayoutObject->{UserID},
        Permission => 'ro',
    );
    push @TicketIDs, @MasterTickets;
    push @TicketIDs, @PrimaryTickets;

    # set dynamic field possible values
    $PossibleValues{Primary} = $LayoutObject->{LanguageObject}->Translate('New Primary Ticket');

    my $TicketHook        = $ConfigObject->Get('Ticket::Hook');
    my $TicketHookDivider = $ConfigObject->Get('Ticket::HookDivider');

    TICKET:
    for my $TicketID (@TicketIDs) {
        my %CurrentTicket = $TicketObject->TicketGet(
            TicketID      => $TicketID,
            DynamicFields => 1,
        );

        next TICKET if !%CurrentTicket;

        # set dynamic field possible values
        $PossibleValues{"SecondaryOf:$CurrentTicket{TicketNumber}"} = $LayoutObject->{LanguageObject}->Translate(
            'Secondary of %s%s%s: %s',
            $TicketHook,
            $TicketHookDivider,
            $CurrentTicket{TicketNumber},
            $CurrentTicket{Title},
        );
    }

   # If config UnsetPrimarySecondary is enabled and we are requesting values from AdminGenericAgent,
   #   add UnsetPrimary and UnsetSecondary possible values. See bug#14778 (https://bugs.otrs.org/show_bug.cgi?id=14778).
    if (
        $ConfigObject->Get('PrimarySecondary::UnsetPrimarySecondary')
        && $LayoutObject->{Action} eq 'AdminGenericAgent'
        )
    {
        $PossibleValues{UnsetPrimary}   = $LayoutObject->{LanguageObject}->Translate('Unset Primary Ticket');
        $PossibleValues{UnsetSecondary} = $LayoutObject->{LanguageObject}->Translate('Unset Secondary Ticket');
    }

    # return the possible values hash as a reference
    return \%PossibleValues;
}

sub _HandleLinks {
    my ( $Self, %Param ) = @_;

    my $LogObject = $Kernel::OM->Get('Kernel::System::Log');

    for my $Needed (qw(FieldName FieldValue TicketID UserID)) {
        if ( !$Param{$Needed} ) {
            $LogObject->Log(
                Priority => 'error',
                Message  => "Need $Needed!",
            );
            return;
        }
    }

    # get ticket object
    my $TicketObject = $Kernel::OM->Get('Kernel::System::Ticket');

    my $FieldName = $Param{FieldName};

    my %Ticket = $Param{Ticket}
        ? %{ $Param{Ticket} }
        : $TicketObject->TicketGet(
        TicketID      => $Param{TicketID},
        DynamicFields => 1,
        );

    my $OldValue = $Ticket{ 'DynamicField_' . $FieldName };

    # get config object
    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');

    # get primary secondary config
    my $PrimarySecondaryKeepParentChildAfterUnset
        = $ConfigObject->Get('PrimarySecondary::KeepParentChildAfterUnset') || 0;
    my $PrimarySecondaryFollowUpdatedPrimary = $ConfigObject->Get('PrimarySecondary::FollowUpdatedPrimary') || 0;
    my $PrimarySecondaryKeepParentChildAfterUpdate
        = $ConfigObject->Get('PrimarySecondary::KeepParentChildAfterUpdate') || 0;

    my $NewValue = $Param{FieldValue};

    # get link object
    my $LinkObject = $Kernel::OM->Get('Kernel::System::LinkObject');

    # set a new primary ticket
    # check if it is already a primary ticket
    if (
        $NewValue eq 'Primary'
        && ( !$OldValue || $OldValue ne $NewValue )
        )
    {

        # check if it was a secondary ticket before and if we have to delete
        # the old parent child link (PrimarySecondaryKeepParentChildAfterUnset)
        if (
            $OldValue
            && $OldValue =~ /^(SecondaryOf|SlaveOf):(.*?)$/
            && !$PrimarySecondaryKeepParentChildAfterUnset
            )
        {
            my $SourceKey = $TicketObject->TicketIDLookup(
                TicketNumber => $2,
                UserID       => $Param{UserID},
            );

            $LinkObject->LinkDelete(
                Object1 => 'Ticket',
                Key1    => $SourceKey,
                Object2 => 'Ticket',
                Key2    => $Param{TicketID},
                Type    => 'ParentChild',
                UserID  => $Param{UserID},
            );
        }
    }

    # set a new secondary ticket
    # check if it's already the secondary of the wished primary ticket
    elsif (
        $NewValue =~ /^(SecondaryOf|SlaveOf):(.*?)$/
        && ( !$OldValue || $OldValue ne $NewValue )
        )
    {
        my $SourceKey = $TicketObject->TicketIDLookup(
            TicketNumber => $2,
            UserID       => $Param{UserID},
        );

        $LinkObject->LinkAdd(
            SourceObject => 'Ticket',
            SourceKey    => $SourceKey,
            TargetObject => 'Ticket',
            TargetKey    => $Param{TicketID},
            Type         => 'ParentChild',
            State        => 'Valid',
            UserID       => $Param{UserID},
        );

        my %Links = $LinkObject->LinkKeyList(
            Object1   => 'Ticket',
            Key1      => $Param{TicketID},
            Object2   => 'Ticket',
            State     => 'Valid',
            Type      => 'ParentChild',      # (optional)
            Direction => 'Target',           # (optional) default Both (Source|Target|Both)
            UserID    => $Param{UserID},
        );

        my @SecondaryTicketIDs;

        LINKEDTICKETID:
        for my $LinkedTicketID ( sort keys %Links ) {
            next LINKEDTICKETID if !$Links{$LinkedTicketID};

            # just take ticket with secondary attributes for action
            my %LinkedTicket = $TicketObject->TicketGet(
                TicketID      => $LinkedTicketID,
                DynamicFields => 1,
            );

            my $LinkedTicketValue = $LinkedTicket{ 'DynamicField_' . $FieldName };

            next LINKEDTICKETID if !$LinkedTicketValue;
            next LINKEDTICKETID if $LinkedTicketValue !~ /^(SecondaryOf|SlaveOf):(.*?)$/;

            # remember linked ticket id
            push @SecondaryTicketIDs, $LinkedTicketID;
        }

        if ( $OldValue && $OldValue =~ /^(Primary|Master)$/ ) {

            if ( $PrimarySecondaryFollowUpdatedPrimary && @SecondaryTicketIDs ) {
                for my $LinkedTicketID (@SecondaryTicketIDs) {
                    $LinkObject->LinkAdd(
                        SourceObject => 'Ticket',
                        SourceKey    => $SourceKey,
                        TargetObject => 'Ticket',
                        TargetKey    => $LinkedTicketID,
                        Type         => 'ParentChild',
                        State        => 'Valid',
                        UserID       => $Param{UserID},
                    );
                }
            }

            if ( !$PrimarySecondaryKeepParentChildAfterUnset ) {
                for my $LinkedTicketID (@SecondaryTicketIDs) {
                    $LinkObject->LinkDelete(
                        Object1 => 'Ticket',
                        Key1    => $Param{TicketID},
                        Object2 => 'Ticket',
                        Key2    => $LinkedTicketID,
                        Type    => 'ParentChild',
                        UserID  => $Param{UserID},
                    );
                }
            }
        }
        elsif (
            $OldValue
            && $OldValue =~ /^(SecondaryOf|SlaveOf):(.*?)$/
            && !$PrimarySecondaryKeepParentChildAfterUpdate
            )
        {
            my $SourceKey = $TicketObject->TicketIDLookup(
                TicketNumber => $2,
                UserID       => $Param{UserID},
            );

            $LinkObject->LinkDelete(
                Object1 => 'Ticket',
                Key1    => $SourceKey,
                Object2 => 'Ticket',
                Key2    => $Param{TicketID},
                Type    => 'ParentChild',
                UserID  => $Param{UserID},
            );
        }
    }
    elsif ( $NewValue =~ /^(?:UnsetPrimary|UnsetSecondary)$/ && $OldValue ) {

        if ( $NewValue eq 'UnsetPrimary' && !$PrimarySecondaryKeepParentChildAfterUnset ) {
            my %Links = $LinkObject->LinkKeyList(
                Object1   => 'Ticket',
                Key1      => $Param{TicketID},
                Object2   => 'Ticket',
                State     => 'Valid',
                Type      => 'ParentChild',      # (optional)
                Direction => 'Target',           # (optional) default Both (Source|Target|Both)
                UserID    => $Param{UserID},
            );

            my @SecondaryTicketIDs;

            LINKEDTICKETID:
            for my $LinkedTicketID ( sort keys %Links ) {
                next LINKEDTICKETID if !$Links{$LinkedTicketID};

                # just take ticket with secondary attributes for action
                my %LinkedTicket = $TicketObject->TicketGet(
                    TicketID      => $LinkedTicketID,
                    DynamicFields => 1,
                );

                my $LinkedTicketValue = $LinkedTicket{ 'DynamicField_' . $FieldName };
                next LINKEDTICKETID if !$LinkedTicketValue;
                next LINKEDTICKETID if $LinkedTicketValue !~ /^(SecondaryOf|SlaveOf):(.*?)$/;

                # remember ticket id
                push @SecondaryTicketIDs, $LinkedTicketID;
            }

            my $PrimarySecondaryDF = $Kernel::OM->Get('Kernel::System::DynamicField')->DynamicFieldGet(
                Name => $FieldName,
            );
            my $DynamicFieldBackendObject = $Kernel::OM->Get('Kernel::System::DynamicField::Backend');

            for my $LinkedTicketID (@SecondaryTicketIDs) {
                $LinkObject->LinkDelete(
                    Object1 => 'Ticket',
                    Key1    => $Param{TicketID},
                    Object2 => 'Ticket',
                    Key2    => $LinkedTicketID,
                    Type    => 'ParentChild',
                    UserID  => $Param{UserID},
                );

                # UnsetSecondary DynamicField value from affected secondary tickets.
                $DynamicFieldBackendObject->ValueSet(
                    DynamicFieldConfig => $PrimarySecondaryDF,
                    FieldID            => $PrimarySecondaryDF->{ID},
                    ObjectID           => $LinkedTicketID,
                    Value              => 'UnsetSecondary',
                    UserID             => $Param{UserID},
                );
            }
        }
        elsif (
            $NewValue eq 'UnsetSecondary'
            && !$PrimarySecondaryKeepParentChildAfterUnset
            && $OldValue =~ /^(SecondaryOf|SlaveOf):(.*?)$/
            )
        {
            my $SourceKey = $TicketObject->TicketIDLookup(
                TicketNumber => $2,
                UserID       => $Param{UserID},
            );

            $LinkObject->LinkDelete(
                Object1 => 'Ticket',
                Key1    => $SourceKey,
                Object2 => 'Ticket',
                Key2    => $Param{TicketID},
                Type    => 'ParentChild',
                UserID  => $Param{UserID},
            );
        }
    }

    return 1;
}

sub SearchFieldRender {
    my ( $Self, %Param ) = @_;

    # take config from field config
    my $FieldConfig = $Param{DynamicFieldConfig}->{Config};
    my $FieldName   = 'Search_DynamicField_' . $Param{DynamicFieldConfig}->{Name};
    my $FieldLabel  = $Param{DynamicFieldConfig}->{Label};

    my $Value;

    my @DefaultValue;

    if ( defined $Param{DefaultValue} ) {
        @DefaultValue = split /;/, $Param{DefaultValue};
    }

    # set the field value
    if (@DefaultValue) {
        $Value = \@DefaultValue;
    }

    # get the field value, this function is always called after the profile is loaded
    my $FieldValues = $Self->SearchFieldValueGet(
        %Param,
    );

    if ( defined $FieldValues ) {
        $Value = $FieldValues;
    }

    # check and set class if necessary
    my $FieldClass = 'DynamicFieldMultiSelect Modernize';

    # set TreeView class
    if ( $FieldConfig->{TreeView} ) {
        $FieldClass .= ' DynamicFieldWithTreeView';
    }

    my $LanguageObject = $Kernel::OM->Get('Kernel::Language');

    # set PossibleValues (primary should be always an option)
    my $SelectionData = {
        Primary => $LanguageObject->Translate('Primary Ticket'),
    };

    # get historical values from database
    my $HistoricalValues = $Self->HistoricalValuesGet(%Param);

    my $TicketObject = $Kernel::OM->Get('Kernel::System::Ticket');

    if ( IsHashRefWithData($HistoricalValues) ) {

        my $ConfigObject      = $Kernel::OM->Get('Kernel::Config');
        my $TicketHook        = $ConfigObject->Get('Ticket::Hook');
        my $TicketHookDivider = $ConfigObject->Get('Ticket::HookDivider');

        # Recreate the display value from the already set tickets.
        VALUE:
        for my $ValueKey ( sort keys %{$HistoricalValues} ) {

            if ( $ValueKey =~ m{(SecondaryOf|SlaveOf):(.*)}gmx ) {
                my $TicketNumber = $2;

                my $TicketID = $TicketObject->TicketIDLookup(
                    TicketNumber => $TicketNumber,
                    UserID       => 1,
                );

                my %Ticket;
                if ($TicketID) {
                    %Ticket = $TicketObject->TicketGet(
                        TicketID => $TicketID
                    );
                }

                next VALUE if !%Ticket;

                $SelectionData->{$ValueKey} = $LanguageObject->Translate(
                    'Secondary of %s%s%s: %s',
                    $TicketHook,
                    $TicketHookDivider,
                    $Ticket{TicketNumber},
                    $Ticket{Title},
                );
            }
        }
    }

    # use PossibleValuesFilter if defined
    $SelectionData = $Param{PossibleValuesFilter} // $SelectionData;

    my $HTMLString = $Param{LayoutObject}->BuildSelection(
        Data         => $SelectionData,
        Name         => $FieldName,
        SelectedID   => $Value,
        Translation  => 0,
        PossibleNone => 0,
        Class        => $FieldClass,
        Multiple     => 1,
        HTMLQuote    => 1,
    );

    # call EditLabelRender on the common Driver
    my $LabelString = $Self->EditLabelRender(
        %Param,
        FieldName => $FieldName,
    );

    my $Data = {
        Field => $HTMLString,
        Label => $LabelString,
    };

    return $Data;
}

1;

=head1 TERMS AND CONDITIONS

This software is part of the OTRS project (L<https://otrs.org/>).

This software comes with ABSOLUTELY NO WARRANTY. For details, see
the enclosed file COPYING for license information (GPL). If you
did not receive this file, see L<https://www.gnu.org/licenses/gpl-3.0.txt>.

=cut
