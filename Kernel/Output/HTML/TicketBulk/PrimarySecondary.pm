# --
# Copyright (C) 2001-2021 OTRS AG, https://otrs.com/
# Copyright (C) 2021 Znuny GmbH, https://znuny.org/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package Kernel::Output::HTML::TicketBulk::PrimarySecondary;

use strict;
use warnings;
use utf8;

use Kernel::Language qw(Translatable);

our @ObjectDependencies = (
    'Kernel::Config',
    'Kernel::Output::HTML::Layout',
    'Kernel::System::DynamicField',
    'Kernel::System::DynamicField::Backend',
    'Kernel::System::Ticket',
    'Kernel::System::Web::Request',
);

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {%Param};
    bless( $Self, $Type );

    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');

    # get Primary/Secondary dynamic field
    $Self->{PrimarySecondaryDynamicField}    = $ConfigObject->Get('PrimarySecondary::DynamicField')    || '';
    $Self->{PrimarySecondaryAdvancedEnabled} = $ConfigObject->Get('PrimarySecondary::AdvancedEnabled') || 0;

    if ( $Self->{PrimarySecondaryDynamicField} ) {
        $Self->{DynamicFieldConfig} = $Kernel::OM->Get('Kernel::System::DynamicField')->DynamicFieldGet(
            Name => $Self->{PrimarySecondaryDynamicField},
        );
    }

    return $Self;
}

sub Display {
    my ( $Self, %Param ) = @_;

    # if there is no configured dynamic field or if advanced mode is not enable, there is nothing to do
    return if !$Self->{PrimarySecondaryDynamicField};
    return if !$Self->{PrimarySecondaryAdvancedEnabled};

    my $ServerError;
    my $ErrorMessage;
    if ( exists $Param{Errors}->{ $Self->{DynamicFieldConfig}->{Name} } ) {
        $ServerError  = 1;
        $ErrorMessage = $Param{Errors}->{ $Self->{DynamicFieldConfig}->{Name} };
    }

    my $PossibleValuesFilter = $Self->_GetPrimarySecondaryData(
        %Param,
        PrimarySecondaryDynamicField => $Self->{PrimarySecondaryDynamicField},
    );

    # get field HTML
    my $DynamicFieldHTML = $Kernel::OM->Get('Kernel::System::DynamicField::Backend')->EditFieldRender(
        DynamicFieldConfig   => $Self->{DynamicFieldConfig},
        PossibleValuesFilter => $PossibleValuesFilter,
        ServerError          => $ServerError || '',
        ErrorMessage         => $ErrorMessage || '',
        LayoutObject         => $Kernel::OM->Get('Kernel::Output::HTML::Layout'),
        ParamObject          => $Kernel::OM->Get('Kernel::System::Web::Request'),
        Mandatory            => 0,
    );

    # indentation here is on purpose so the HTML will look according to the framework
    my $HTMLString = <<"EOF";
                    $DynamicFieldHTML->{Label}
                    <div class="Field">
                        $DynamicFieldHTML->{Field}
                    </div>
                    <div class="Clear"></div>
EOF

    return $HTMLString;
}

sub Validate {
    my ( $Self, %Param ) = @_;

    # if there is no configured dynamic field or if advanced mode is not enable, there is nothing to do
    return if !$Self->{PrimarySecondaryDynamicField};
    return if !$Self->{PrimarySecondaryAdvancedEnabled};

    my $PossibleValuesFilter = $Self->_GetPrimarySecondaryData(
        %Param,
        PrimarySecondaryDynamicField => $Self->{PrimarySecondaryDynamicField},
    );

    my $ValidationResult = $Kernel::OM->Get('Kernel::System::DynamicField::Backend')->EditFieldValueValidate(
        DynamicFieldConfig   => $Self->{DynamicFieldConfig},
        PossibleValuesFilter => $PossibleValuesFilter,
        ParamObject          => $Kernel::OM->Get('Kernel::System::Web::Request'),
        Mandatory            => 0,
    );

    if ( $ValidationResult->{ServerError} ) {
        return (
            {
                ErrorKey   => $Self->{DynamicFieldConfig}->{Name},
                ErrorValue => $ValidationResult->{ErrorMessage},
            }
        );
    }

    return;
}

sub Store {
    my ( $Self, %Param ) = @_;

    # if there is no configured dynamic field or if advanced mode is not enable, there is nothing to do
    return 1 if !$Self->{PrimarySecondaryDynamicField};
    return 1 if !$Self->{PrimarySecondaryAdvancedEnabled};

    # get needed objects
    my $DynamicFieldBackendObject = $Kernel::OM->Get('Kernel::System::DynamicField::Backend');

    # extract the dynamic field value form the web request
    my $DynamicFieldValue = $DynamicFieldBackendObject->EditFieldValueGet(
        DynamicFieldConfig => $Self->{DynamicFieldConfig},
        ParamObject        => $Kernel::OM->Get('Kernel::System::Web::Request'),
        LayoutObject       => $Kernel::OM->Get('Kernel::Output::HTML::Layout'),
    );

    # set the value
    my $Success = $DynamicFieldBackendObject->ValueSet(
        DynamicFieldConfig => $Self->{DynamicFieldConfig},
        ObjectID           => $Param{TicketID},
        Value              => $DynamicFieldValue,
        UserID             => $Param{UserID},
    );

    return 1;
}

sub _GetPrimarySecondaryData {
    my ( $Self, %Param ) = @_;

    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');
    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');

    # get primary secondary config
    my $UnsetPrimarySecondary  = $ConfigObject->Get('PrimarySecondary::UnsetPrimarySecondary')  || 0;
    my $UpdatePrimarySecondary = $ConfigObject->Get('PrimarySecondary::UpdatePrimarySecondary') || 0;

    my %Data = (
        ''      => '-',
        Primary => $LayoutObject->{LanguageObject}->Translate('New Primary Ticket'),
    );

    if ($UnsetPrimarySecondary) {
        $Data{UnsetPrimary}   = Translatable('Unset Primary Tickets');
        $Data{UnsetSecondary} = Translatable('Unset Secondary Tickets');
    }

    # get needed objects
    my $TicketObject = $Kernel::OM->Get('Kernel::System::Ticket');

    if ($UpdatePrimarySecondary) {

        # find all current open primary secondary tickets and the legacy master slave tickets
        my @TicketIDs;
        my @PrimaryTickets = $TicketObject->TicketSearch(
            Result => 'ARRAY',

            # primary secondary dynamic field
            'DynamicField_' . $Param{PrimarySecondaryDynamicField} => {
                Equals => 'Primary',
            },

            StateType  => 'Open',
            Limit      => 60,
            UserID     => $Param{UserID},
            Permission => 'ro',
        );
        my @MasterTickets = $TicketObject->TicketSearch(
            Result => 'ARRAY',

            # primary secondary dynamic field
            'DynamicField_' . $Param{PrimarySecondaryDynamicField} => {
                Equals => 'Master',
            },

            StateType  => 'Open',
            Limit      => 60,
            UserID     => $Param{UserID},
            Permission => 'ro',
        );
        push @TicketIDs, @MasterTickets;
        push @TicketIDs, @PrimaryTickets;

        my $TicketHook        = $ConfigObject->Get('Ticket::Hook');
        my $TicketHookDivider = $ConfigObject->Get('Ticket::HookDivider');

        TICKETID:
        for my $TicketID (@TicketIDs) {

            # get each ticket from the search results
            my %CurrentTicket = $TicketObject->TicketGet(
                TicketID => $TicketID
            );
            next TICKETID if !%CurrentTicket;

            $Data{"SecondaryOf:$CurrentTicket{TicketNumber}"} = $LayoutObject->{LanguageObject}->Translate(
                'Secondary of %s%s%s: %s',
                $TicketHook,
                $TicketHookDivider,
                $CurrentTicket{TicketNumber},
                $CurrentTicket{Title},
            );
        }
    }
    return \%Data;

}
1;
