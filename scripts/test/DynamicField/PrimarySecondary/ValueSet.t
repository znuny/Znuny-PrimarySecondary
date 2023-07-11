# --
# Copyright (C) 2001-2021 OTRS AG, https://otrs.com/
# Copyright (C) 2021 Znuny GmbH, https://znuny.org/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

use strict;
use warnings;
use utf8;

use vars (qw($Self));
use Kernel::System::VariableCheck qw(IsHashRefWithData);

# get needed objects
my $TicketObject              = $Kernel::OM->Get('Kernel::System::Ticket');
my $LinkObject                = $Kernel::OM->Get('Kernel::System::LinkObject');
my $DynamicFieldObject        = $Kernel::OM->Get('Kernel::System::DynamicField');
my $DynamicFieldBackendObject = $Kernel::OM->Get('Kernel::System::DynamicField::Backend');
my $ConfigObject              = $Kernel::OM->Get('Kernel::Config');

# get helper object
$Kernel::OM->ObjectParamAdd(
    'Kernel::System::UnitTest::Helper' => {
        RestoreDatabase => 1,
    },
);
my $HelperObject = $Kernel::OM->Get('Kernel::System::UnitTest::Helper');

# ------------------------------------------------------------ #
# make preparations
# ------------------------------------------------------------ #

# get Primary/Secondary dynamic field data
my $PrimarySecondaryDynamicField     = $ConfigObject->Get('PrimarySecondary::DynamicField');
my $PrimarySecondaryDynamicFieldData = $DynamicFieldObject->DynamicFieldGet(
    Name => $PrimarySecondaryDynamicField,
);

# get random ID
my $RandomID = $HelperObject->GetRandomID();

# create test tickets
my @TicketIDs;
my @TicketNumbers;
for my $Ticket ( 1 .. 3 ) {
    my $TicketNumber = $TicketObject->TicketCreateNumber();
    my $TicketID     = $TicketObject->TicketCreate(
        TN           => $TicketNumber,
        Title        => 'Unit test ticket ' . $RandomID . ' ' . $Ticket,
        Queue        => 'Raw',
        Lock         => 'unlock',
        Priority     => '3 normal',
        State        => 'new',
        CustomerNo   => '123465',
        CustomerUser => 'customer@example.com',
        OwnerID      => 1,
        UserID       => 1,
    );
    $Self->True(
        $TicketID,
        "TicketCreate() Ticket ID $TicketID - TN: $TicketNumber",
    );
    push @TicketIDs,     $TicketID;
    push @TicketNumbers, $TicketNumber;
}

# ------------------------------------------------------------ #
# test Primary/Secondary ticket value set
# ------------------------------------------------------------ #

# set first test ticket as primary ticket
my $Success = $DynamicFieldBackendObject->ValueSet(
    DynamicFieldConfig => $PrimarySecondaryDynamicFieldData,
    FieldID            => $PrimarySecondaryDynamicFieldData->{ID},
    ObjectID           => $TicketIDs[0],
    Value              => 'Primary',
    UserID             => 1,
);
$Self->True(
    $Success,
    "ValueSet() Ticket ID $TicketIDs[0] DynamicField $PrimarySecondaryDynamicField updated as PrimaryTicket",
);

# set second test ticket as secondary ticket
$Success = $DynamicFieldBackendObject->ValueSet(
    DynamicFieldConfig => $PrimarySecondaryDynamicFieldData,
    FieldID            => $PrimarySecondaryDynamicFieldData->{ID},
    ObjectID           => $TicketIDs[1],
    Value              => "SecondaryOf:$TicketNumbers[0]",
    UserID             => 1,
);
$Self->True(
    $Success,
    "ValueSet() Ticket ID $TicketIDs[1] DynamicField $PrimarySecondaryDynamicField updated as SecondaryOf:$TicketNumbers[0]",
);

# verify there is parent-child link between Primary/Secondary tickets
my %LinkKeyList = $LinkObject->LinkKeyList(
    Object1   => 'Ticket',
    Key1      => $TicketIDs[0],
    Object2   => 'Ticket',
    State     => 'Valid',
    Type      => 'ParentChild',
    Direction => 'Both',
    UserID    => 1,
);

$Self->True(
    IsHashRefWithData( \%LinkKeyList ) ? 1 : 0,
    "LinkKeyList() Primary/Secondary link found - Ticket ID $TicketIDs[0] and $TicketIDs[1]",
);

# ------------------------------------------------------------ #
# test UnsetPrimary|UnsetSecondary
# ------------------------------------------------------------ #

# enable the PrimarySecondary::KeepParentChildAfterUnset sysconfig
$Success = $ConfigObject->Set(
    Key   => 'PrimarySecondary::KeepParentChildAfterUnset',
    Value => 1
);
$Self->True(
    $Success,
    "Set() sysconfig KeepParentChildAfterUnset - enabled",
);

# set second ticket as secondary ticket again
$Success = $DynamicFieldBackendObject->ValueSet(
    DynamicFieldConfig => $PrimarySecondaryDynamicFieldData,
    FieldID            => $PrimarySecondaryDynamicFieldData->{ID},
    ObjectID           => $TicketIDs[1],
    Value              => "SecondaryOf:$TicketNumbers[0]",
    UserID             => 1,
);
$Self->True(
    $Success,
    "ValueSet() Ticket ID $TicketIDs[1] DynamicField $PrimarySecondaryDynamicField updated again as SecondaryOf:$TicketNumbers[0]",
);

# verify there is parent-child link between Primary/Secondary tickets
%LinkKeyList = $LinkObject->LinkKeyList(
    Object1   => 'Ticket',
    Key1      => $TicketIDs[0],
    Object2   => 'Ticket',
    State     => 'Valid',
    Type      => 'ParentChild',
    Direction => 'Target',
    UserID    => 1,
);
$Self->True(
    IsHashRefWithData( \%LinkKeyList ) ? 1 : 0,
    "LinkKeyList() Primary/Secondary link found - Ticket ID $TicketIDs[0] and $TicketIDs[1]",
);

# UnsetPrimary value from first ticket
$Success = $DynamicFieldBackendObject->ValueSet(
    DynamicFieldConfig => $PrimarySecondaryDynamicFieldData,
    FieldID            => $PrimarySecondaryDynamicFieldData->{ID},
    ObjectID           => $TicketIDs[0],
    Value              => 'UnsetPrimary',
    UserID             => 1,
);
$Self->True(
    $Success,
    "ValueSet() Ticket ID $TicketIDs[0] DynamicField $PrimarySecondaryDynamicField updated as UnsetPrimary",
);

# UnsetSecondary value from second ticket
$Success = $DynamicFieldBackendObject->ValueSet(
    DynamicFieldConfig => $PrimarySecondaryDynamicFieldData,
    FieldID            => $PrimarySecondaryDynamicFieldData->{ID},
    ObjectID           => $TicketIDs[1],
    Value              => 'UnsetSecondary',
    UserID             => 1,
);
$Self->True(
    $Success,
    "ValueSet() Ticket ID $TicketIDs[1] DynamicField $PrimarySecondaryDynamicField updated as UnsetSecondary",
);

# verify there is still parent-child link between two tickets
%LinkKeyList = $LinkObject->LinkKeyList(
    Object1   => 'Ticket',
    Key1      => $TicketIDs[0],
    Object2   => 'Ticket',
    State     => 'Valid',
    Type      => 'ParentChild',
    Direction => 'Target',
    UserID    => 1,
);
$Self->True(
    IsHashRefWithData( \%LinkKeyList ) ? 1 : 0,
    "LinkKeyList() Primary/Secondary link found - Ticket ID $TicketIDs[0] and $TicketIDs[1] - KeepParentChildAfterUnset sysconfig enabled",
);

# disable the PrimarySecondary::KeepParentChildAfterUnset sysconfig
$Success = $ConfigObject->Set(
    Key   => 'PrimarySecondary::KeepParentChildAfterUnset',
    Value => 0
);
$Self->True(
    $Success,
    "Set() sysconfig KeepParentChildAfterUnset - disabled",
);

# remove parent-child link between two tickets
$Success = $LinkObject->LinkDeleteAll(
    Object => 'Ticket',
    Key    => $TicketIDs[0],
    UserID => 1,
);
$Self->True(
    $Success,
    "LinkDeleteAll() parent-child link for ticket ID $TicketIDs[0] - removed",
);

# set first test ticket as primary ticket
$Success = $DynamicFieldBackendObject->ValueSet(
    DynamicFieldConfig => $PrimarySecondaryDynamicFieldData,
    FieldID            => $PrimarySecondaryDynamicFieldData->{ID},
    ObjectID           => $TicketIDs[0],
    Value              => 'Primary',
    UserID             => 1,
);
$Self->True(
    $Success,
    "ValueSet() Ticket ID $TicketIDs[0] DynamicField $PrimarySecondaryDynamicField updated as PrimaryTicket",
);

# set second test ticket as secondary ticket
$Success = $DynamicFieldBackendObject->ValueSet(
    DynamicFieldConfig => $PrimarySecondaryDynamicFieldData,
    FieldID            => $PrimarySecondaryDynamicFieldData->{ID},
    ObjectID           => $TicketIDs[1],
    Value              => "SecondaryOf:$TicketNumbers[0]",
    UserID             => 1,
);
$Self->True(
    $Success,
    "ValueSet() Ticket ID $TicketIDs[1] DynamicField $PrimarySecondaryDynamicField updated as SecondaryOf:$TicketNumbers[0]",
);

# verify there is still parent-child link between two tickets
%LinkKeyList = $LinkObject->LinkKeyList(
    Object1   => 'Ticket',
    Key1      => $TicketIDs[0],
    Object2   => 'Ticket',
    State     => 'Valid',
    Type      => 'ParentChild',
    Direction => 'Target',
    UserID    => 1,
);
$Self->True(
    IsHashRefWithData( \%LinkKeyList ) ? 1 : 0,
    "LinkKeyList() Primary/Secondary link found - Ticket ID $TicketIDs[0] and $TicketIDs[1]",
);

# UnsetPrimary value from first ticket
$Success = $DynamicFieldBackendObject->ValueSet(
    DynamicFieldConfig => $PrimarySecondaryDynamicFieldData,
    FieldID            => $PrimarySecondaryDynamicFieldData->{ID},
    ObjectID           => $TicketIDs[0],
    Value              => 'UnsetPrimary',
    UserID             => 1,
);
$Self->True(
    $Success,
    "ValueSet() Ticket ID $TicketIDs[0] DynamicField $PrimarySecondaryDynamicField updated as UnsetPrimary",
);

# UnsetSecondary value from second ticket
$Success = $DynamicFieldBackendObject->ValueSet(
    DynamicFieldConfig => $PrimarySecondaryDynamicFieldData,
    FieldID            => $PrimarySecondaryDynamicFieldData->{ID},
    ObjectID           => $TicketIDs[1],
    Value              => 'UnsetSecondary',
    UserID             => 1,
);
$Self->True(
    $Success,
    "ValueSet() Ticket ID $TicketIDs[1] DynamicField $PrimarySecondaryDynamicField updated as UnsetSecondary",
);

# verify there is no more parent-child link between two tickets
%LinkKeyList = $LinkObject->LinkKeyList(
    Object1   => 'Ticket',
    Key1      => $TicketIDs[0],
    Object2   => 'Ticket',
    State     => 'Valid',
    Type      => 'ParentChild',
    Direction => 'Target',
    UserID    => 1,
);
$Self->True(
    !IsHashRefWithData( \%LinkKeyList ),
    "LinkKeyList() Primary/Secondary link removed - Ticket ID $TicketIDs[0] and $TicketIDs[1] - KeepParentChildAfterUnset sysconfig disabled",
);

# ------------------------------------------------------------ #
# test update Primary/Secondary field
# ------------------------------------------------------------ #

# enable the PrimarySecondary::KeepParentChildAfterUpdate sysconfig
$Success = $ConfigObject->Set(
    Key   => 'PrimarySecondary::KeepParentChildAfterUpdate',
    Value => 1
);
$Self->True(
    $Success,
    "Set() sysconfig KeepParentChildAfterUpdate - enabled",
);

# set first test ticket as primary ticket
$Success = $DynamicFieldBackendObject->ValueSet(
    DynamicFieldConfig => $PrimarySecondaryDynamicFieldData,
    FieldID            => $PrimarySecondaryDynamicFieldData->{ID},
    ObjectID           => $TicketIDs[0],
    Value              => 'Primary',
    UserID             => 1,
);
$Self->True(
    $Success,
    "ValueSet() Ticket ID $TicketIDs[0] DynamicField $PrimarySecondaryDynamicField updated as PrimaryTicket",
);

# set second test ticket as primary ticket
$Success = $DynamicFieldBackendObject->ValueSet(
    DynamicFieldConfig => $PrimarySecondaryDynamicFieldData,
    FieldID            => $PrimarySecondaryDynamicFieldData->{ID},
    ObjectID           => $TicketIDs[1],
    Value              => "Primary",
    UserID             => 1,
);
$Self->True(
    $Success,
    "ValueSet() Ticket ID $TicketIDs[1] DynamicField $PrimarySecondaryDynamicField updated as PrimaryTicket",
);

# set third test ticket as secondary of second ticket
$Success = $DynamicFieldBackendObject->ValueSet(
    DynamicFieldConfig => $PrimarySecondaryDynamicFieldData,
    FieldID            => $PrimarySecondaryDynamicFieldData->{ID},
    ObjectID           => $TicketIDs[2],
    Value              => "SecondaryOf:$TicketNumbers[1]",
    UserID             => 1,
);
$Self->True(
    $Success,
    "ValueSet() Ticket ID $TicketIDs[2] DynamicField $PrimarySecondaryDynamicField updated as SecondaryOf:$TicketNumbers[1]",
);

# verify there is parent-child link between two tickets
%LinkKeyList = $LinkObject->LinkKeyList(
    Object1   => 'Ticket',
    Key1      => $TicketIDs[1],
    Object2   => 'Ticket',
    State     => 'Valid',
    Type      => 'ParentChild',
    Direction => 'Target',
    UserID    => 1,
);
$Self->True(
    IsHashRefWithData( \%LinkKeyList ) ? 1 : 0,
    "LinkKeyList() Primary/Secondary link found - Ticket ID $TicketIDs[1] and $TicketIDs[2]",
);

# set second ticket as secondary of first ticket
$Success = $DynamicFieldBackendObject->ValueSet(
    DynamicFieldConfig => $PrimarySecondaryDynamicFieldData,
    FieldID            => $PrimarySecondaryDynamicFieldData->{ID},
    ObjectID           => $TicketIDs[1],
    Value              => "SecondaryOf:$TicketNumbers[0]",
    UserID             => 1,
);
$Self->True(
    $Success,
    "ValueSet() Ticket ID $TicketIDs[1] DynamicField $PrimarySecondaryDynamicField updated as SecondaryOf:$TicketNumbers[0]",
);

# verify there parent-child-parent link between three tickets
%LinkKeyList = $LinkObject->LinkKeyList(
    Object1   => 'Ticket',
    Key1      => $TicketIDs[1],
    Object2   => 'Ticket',
    State     => 'Valid',
    Type      => 'ParentChild',
    Direction => 'Both',
    UserID    => 1,
);
$Self->True(
    IsHashRefWithData( \%LinkKeyList ),
    "LinkKeyList() Primary/Secondary link found - Ticket ID $TicketIDs[0], $TicketIDs[1] and $TicketIDs[2] - KeepParentChildAfterUpdate sysconfig enabled",
);

# Cleanup is done by RestoreDatabase.

1;
