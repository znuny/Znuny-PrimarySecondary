# --
# Copyright (C) 2001-2021 OTRS AG, https://otrs.com/
# Copyright (C) 2021 Znuny GmbH, https://znuny.org/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package Kernel::Modules::AgentPrePrimarySecondary;

use strict;
use warnings;
use utf8;

# prevent used once warning
use Kernel::System::ObjectManager;

our $ObjectManagerDisabled = 1;

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {%Param};
    bless( $Self, $Type );

    return $Self;
}

sub PreRun {
    my ( $Self, %Param ) = @_;

    # do only use this in phone and email ticket
    return if ( $Self->{Action} !~ /^AgentTicket(Email|Phone)$/ );

    # get config object
    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');

    # get primary/secondary dynamic field
    my $PrimarySecondaryDynamicField = $ConfigObject->Get('PrimarySecondary::DynamicField') || '';

    # return if no config option is used
    return if !$PrimarySecondaryDynamicField;

    # set dynamic field as shown
    $ConfigObject->{"Ticket::Frontend::$Self->{Action}"}->{DynamicField}->{$PrimarySecondaryDynamicField} = 1;

    return;
}

1;
