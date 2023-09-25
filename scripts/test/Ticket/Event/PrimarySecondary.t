# --
# Copyright (C) 2001-2021 OTRS AG, https://otrs.com/
# Copyright (C) 2021 Znuny GmbH, https://znuny.org/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

## no critic (Modules::RequireExplicitPackage)
use strict;
use warnings;
use utf8;

use vars (qw($Self));

# get needed objects
my $TicketObject              = $Kernel::OM->Get('Kernel::System::Ticket');
my $DynamicFieldBackendObject = $Kernel::OM->Get('Kernel::System::DynamicField::Backend');
my $LinkObject                = $Kernel::OM->Get('Kernel::System::LinkObject');
my $DynamicFieldObject        = $Kernel::OM->Get('Kernel::System::DynamicField');
my $UserObject                = $Kernel::OM->Get('Kernel::System::User');
my $CustomerUserObject        = $Kernel::OM->Get('Kernel::System::CustomerUser');
my $ConfigObject              = $Kernel::OM->Get('Kernel::Config');

# start RestoreDatabse
$Kernel::OM->ObjectParamAdd(
    'Kernel::System::UnitTest::Helper' => {
        RestoreDatabase => 1,
    },
);
my $HelperObject = $Kernel::OM->Get('Kernel::System::UnitTest::Helper');

# ------------------------------------------------------------ #
# make preparations
# ------------------------------------------------------------ #

# enable config PrimarySecondary::ForwardSecondary
$ConfigObject->Set(
    Key   => 'PrimarySecondary::ForwardSecondary',
    Value => 1,
);
$ConfigObject->Set(
    Key   => 'CheckMXRecord',
    Value => 0,
);
$ConfigObject->Set(
    Key   => 'CheckEmailAddresses',
    Value => 0,
);

# get random ID
my $RandomID = $HelperObject->GetRandomID();

# get Primary/Secondary dynamic field data
my $PrimarySecondaryDynamicField     = $ConfigObject->Get('PrimarySecondary::DynamicField');
my $PrimarySecondaryDynamicFieldData = $DynamicFieldObject->DynamicFieldGet(
    Name => $PrimarySecondaryDynamicField,
);

# create new user
my $TestUserLogin = $HelperObject->TestUserCreate(
    Groups   => [ 'admin', 'users' ],
    Language => 'en'
);
$Self->True(
    $TestUserLogin,
    "UserAdd() $TestUserLogin",
);

# create new customer user
my $TestCustomerUserLogin = $HelperObject->TestCustomerUserCreate(
    Language => 'en',
);
$Self->True(
    $TestCustomerUserLogin,
    "CustomerUserAdd() $TestCustomerUserLogin",
);

# create first test ticket
my $PrimaryTicketNumber = $TicketObject->TicketCreateNumber();
my $PrimaryTicketID     = $TicketObject->TicketCreate(
    TN           => $PrimaryTicketNumber,
    Title        => 'Primary unit test ticket ' . $RandomID,
    Queue        => 'Raw',
    Lock         => 'unlock',
    Priority     => '3 normal',
    State        => 'new',
    CustomerNo   => $TestCustomerUserLogin,
    CustomerUser => $TestCustomerUserLogin,
    ,
    OwnerID => 1,
    UserID  => 1,
);
$Self->True(
    $PrimaryTicketID,
    "TicketCreate() Ticket ID $PrimaryTicketID",
);

my $ArticleObject      = $Kernel::OM->Get('Kernel::System::Ticket::Article');
my $EmailBackendObject = $ArticleObject->BackendForChannel(
    ChannelName => 'Email',
);

# create article for test ticket
my $ArticleID = $EmailBackendObject->ArticleCreate(
    TicketID             => $PrimaryTicketID,
    IsVisibleForCustomer => 1,
    SenderType           => 'agent',
    Subject              => 'Primary Article',
    Body                 => 'Unit test PrimaryTicket',
    ContentType          => 'text/plain; charset=ISO-8859-15',
    HistoryType          => 'EmailCustomer',
    HistoryComment       => 'Unit test article',
    UserID               => 1,
);
$Self->True(
    $ArticleID,
    "ArticleCreate() Article ID $ArticleID",
);

my $DynamicField = $DynamicFieldObject->DynamicFieldGet(
    ID => $PrimarySecondaryDynamicFieldData->{ID},
);

# set test ticket as Primary ticket
my $Success = $DynamicFieldBackendObject->ValueSet(
    DynamicFieldConfig => $DynamicField,
    ObjectID           => $PrimaryTicketID,
    Value              => 'Primary',
    UserID             => 1,
);
$Self->True(
    $Success,
    "ValueSet() Ticket ID $PrimaryTicketID DynamicField $PrimarySecondaryDynamicField updated as PrimaryTicket",
);

# create second test ticket
my $SecondaryTicketNumber = $TicketObject->TicketCreateNumber();
my $SecondaryTicketID     = $TicketObject->TicketCreate(
    TN           => $SecondaryTicketNumber,
    Title        => 'Secondary unit test ticket ' . $RandomID,
    Queue        => 'Raw',
    Lock         => 'unlock',
    Priority     => '3 normal',
    State        => 'new',
    CustomerID   => $TestCustomerUserLogin,
    CustomerUser => $TestCustomerUserLogin . '@localunittest.com',
    OwnerID      => 1,
    UserID       => 1,
);
$Self->True(
    $SecondaryTicketID,
    "TicketCreate() Ticket ID $SecondaryTicketID",
);
$Success = $DynamicFieldBackendObject->ValueSet(
    DynamicFieldConfig => $DynamicField,
    ObjectID           => $SecondaryTicketID,
    Value              => "SecondaryOf:$PrimaryTicketNumber",
    UserID             => 1,
);

# ------------------------------------------------------------ #
# test event ArticleSend
# ------------------------------------------------------------ #

# create Primary ticket article and forward it
my $PrimaryNewSubject = $TicketObject->TicketSubjectBuild(
    TicketNumber => $PrimaryTicketNumber,
    Subject      => 'Primary Article',
    Action       => 'Forward',
);
my $ForwardArticleID = $EmailBackendObject->ArticleSend(
    TicketID             => $PrimaryTicketID,
    IsVisibleForCustomer => 1,
    SenderType           => 'agent',
    From                 => 'Some Agent <email@example.com>',
    To                   => 'Some Customer A <customer-a@example.com>',
    Subject              => $PrimaryNewSubject,
    Body                 => 'Unit test forwarded article',
    Charset              => 'iso-8859-15',
    MimeType             => 'text/plain',
    HistoryType          => 'Forward',
    HistoryComment       => 'Forwarded article',
    NoAgentNotify        => 0,
    UserID               => 1,
);
$Self->True(
    $Success,
    "ArticleSend() Forwarded PrimaryTicket Article ID $ForwardArticleID",
);

# get Primary ticket history
my @PrimaryHistoryLines = $TicketObject->HistoryGet(
    TicketID => $PrimaryTicketID,
    UserID   => 1,
);

my $PrimaryLastHistoryEntry = $PrimaryHistoryLines[-1];

# verify Primary ticket article is created
$Self->IsDeeply(
    $PrimaryLastHistoryEntry->{Name},
    'PrimaryTicketAction: ArticleSend',
    "PrimaryTicket ArticleSend event - ",
);

# get secondary ticket history
my @SecondaryHistoryLines = $TicketObject->HistoryGet(
    TicketID => $SecondaryTicketID,
    UserID   => 1,
);
my $SecondaryLastHistoryEntry = $SecondaryHistoryLines[-1];

# verify secondary ticket article tried to send
$Self->IsDeeply(
    $SecondaryLastHistoryEntry->{Name},
    'PrimaryTicket: no customer email found, send no primary message to customer.',
    "SecondaryTicket ArticleSend event - ",
);

# ------------------------------------------------------------ #
# test event ArticleCreate
# ------------------------------------------------------------ #
my $InternalBackendObject = $ArticleObject->BackendForChannel(
    ChannelName => 'Internal',
);

# create note article for Primary ticket
my $ArticleIDCreate = $InternalBackendObject->ArticleCreate(
    TicketID             => $PrimaryTicketID,
    IsVisibleForCustomer => 0,
    SenderType           => 'agent',
    Subject              => 'Note article',
    Body                 => 'Unit test PrimaryTicket',
    ContentType          => 'text/plain; charset=ISO-8859-15',
    HistoryType          => 'AddNote',
    HistoryComment       => 'Unit test article',
    UserID               => 1,
);
$Self->True(
    $ArticleIDCreate,
    "ArticleCreate() Note Article ID $ArticleIDCreate created for PrimaryTicket ID $PrimaryTicketID",
);

# get Primary ticket history
@PrimaryHistoryLines = $TicketObject->HistoryGet(
    TicketID => $PrimaryTicketID,
    UserID   => 1,
);
($PrimaryLastHistoryEntry) = grep { $_->{Name} eq 'PrimaryTicketAction: ArticleCreate' } @PrimaryHistoryLines;

# verify Primary ticket article is created
$Self->IsDeeply(
    $PrimaryLastHistoryEntry->{Name},
    'PrimaryTicketAction: ArticleCreate',
    "PrimaryTicket ArticleCreate event - ",
);

# get secondary ticket history
@SecondaryHistoryLines = $TicketObject->HistoryGet(
    TicketID => $SecondaryTicketID,
    UserID   => 1,
);

($SecondaryLastHistoryEntry) = grep { $_->{Name} eq 'Added article based on primary ticket.' } @SecondaryHistoryLines;

# verify secondary ticket article is created
$Self->IsDeeply(
    $SecondaryLastHistoryEntry->{Name},
    'Added article based on primary ticket.',
    "SecondaryTicket ArticleCreate event - ",
);

# ------------------------------------------------------------ #
# test event TicketStateUpdate
# ------------------------------------------------------------ #

# change Primary ticket state to 'open'
$Success = $TicketObject->TicketStateSet(
    State    => 'open',
    TicketID => $PrimaryTicketID,
    UserID   => 1,
);
$Self->True(
    $Success,
    "TicketStateSet() PrimaryTicket state updated - 'open'",
);

# get Primary ticket history
@PrimaryHistoryLines = $TicketObject->HistoryGet(
    TicketID => $PrimaryTicketID,
    UserID   => 1,
);
$PrimaryLastHistoryEntry = $PrimaryHistoryLines[-1];

# verify Primary ticket state is updated
$Self->IsDeeply(
    $PrimaryLastHistoryEntry->{Name},
    'PrimaryTicketAction: TicketStateUpdate',
    "PrimaryTicket TicketStateUpdate event - ",
);

# verify secondary ticket state is updated
my %SecondaryTicketData = $TicketObject->TicketGet(
    TicketID => $SecondaryTicketID,
    UserID   => 1,
);

$Self->IsDeeply(
    $SecondaryTicketData{State},
    'open',
    "SecondaryTicket state updated - 'open' - ",
);

# ------------------------------------------------------------ #
# test event TicketPendingTimeUpdate
# ------------------------------------------------------------ #

# change pending time for Primary ticket
$Success = $TicketObject->TicketPendingTimeSet(
    Year     => 0000,
    Month    => 00,
    Day      => 00,
    Hour     => 00,
    Minute   => 00,
    TicketID => $PrimaryTicketID,
    UserID   => 1,
);
$Self->True(
    $Success,
    "TicketPendingTimeSet() PrimaryTicket pending time updated",
);

# get Primary ticket history
@PrimaryHistoryLines = $TicketObject->HistoryGet(
    TicketID => $PrimaryTicketID,
    UserID   => 1,
);
$PrimaryLastHistoryEntry = $PrimaryHistoryLines[-1];

# verify Primary ticket pending time is updated
$Self->IsDeeply(
    $PrimaryLastHistoryEntry->{Name},
    'PrimaryTicketAction: TicketPendingTimeUpdate',
    "PrimaryTicket TicketPendingTimeUpdate event - ",
);

# get secondary ticket history
@SecondaryHistoryLines = $TicketObject->HistoryGet(
    TicketID => $SecondaryTicketID,
    UserID   => 1,
);
$SecondaryLastHistoryEntry = $SecondaryHistoryLines[-1];

# verify secondary ticket pending time is updated
$Self->IsDeeply(
    $SecondaryLastHistoryEntry->{Name},
    '%%00-00-00 00:00',
    "SecondaryTicket pending time update - ",
);

# ------------------------------------------------------------ #
# test event TicketPriorityUpdate
# ------------------------------------------------------------ #

# change Primary ticket priority to '2 low'
$Success = $TicketObject->TicketPrioritySet(
    TicketID => $PrimaryTicketID,
    Priority => '2 low',
    UserID   => 1,
);
$Self->True(
    $Success,
    "TicketPrioritySet() PrimaryTicket priority updated - '2 low'",
);

# get Primary ticket history
@PrimaryHistoryLines = $TicketObject->HistoryGet(
    TicketID => $PrimaryTicketID,
    UserID   => 1,
);
$PrimaryLastHistoryEntry = $PrimaryHistoryLines[-1];

# verify Primary ticket priority is updated
$Self->IsDeeply(
    $PrimaryLastHistoryEntry->{Name},
    'PrimaryTicketAction: TicketPriorityUpdate',
    "PrimaryTicket TicketPriorityUpdate event - ",
);

# verify secondary ticket priority is updated
%SecondaryTicketData = $TicketObject->TicketGet(
    TicketID => $SecondaryTicketID,
    UserID   => 1,
);
$Self->IsDeeply(
    $SecondaryTicketData{Priority},
    '2 low',
    "SecondaryTicket priority updated - '2 low' - ",
);

# ------------------------------------------------------------ #
# test event TicketOwnerUpdate
# ------------------------------------------------------------ #

# change Primary ticket owner
$Success = $TicketObject->TicketOwnerSet(
    TicketID => $PrimaryTicketID,
    NewUser  => $TestUserLogin,
    UserID   => 1,
);
$Self->True(
    $Success,
    "TicketOwnerSet() PrimaryTicket owner updated - $TestUserLogin",
);

# get Primary ticket history
@PrimaryHistoryLines = $TicketObject->HistoryGet(
    TicketID => $PrimaryTicketID,
    UserID   => 1,
);
$PrimaryLastHistoryEntry = $PrimaryHistoryLines[-1];

# verify Primary ticket owner is updated
$Self->IsDeeply(
    $PrimaryLastHistoryEntry->{Name},
    'PrimaryTicketAction: TicketOwnerUpdate',
    "PrimaryTicket TicketOwnerUpdate event - ",
);

# verify secondary ticket owner is updated
%SecondaryTicketData = $TicketObject->TicketGet(
    TicketID => $SecondaryTicketID,
    UserID   => 1,
);
$Self->IsDeeply(
    $SecondaryTicketData{Owner},
    $TestUserLogin,
    "SecondaryTicket owner updated - ",
);

# ------------------------------------------------------------ #
# test event TicketResponsibleUpdate
# ------------------------------------------------------------ #

# set new responsible user for Primary ticket
$Success = $TicketObject->TicketResponsibleSet(
    TicketID => $PrimaryTicketID,
    NewUser  => $TestUserLogin,
    UserID   => 1,
);
$Self->True(
    $Success,
    "TicketResponsibleSet() PrimaryTicket responsible updated - $TestUserLogin",
);

# get Primary ticket history
@PrimaryHistoryLines = $TicketObject->HistoryGet(
    TicketID => $PrimaryTicketID,
    UserID   => 1,
);
$PrimaryLastHistoryEntry = $PrimaryHistoryLines[-1];

# verify Primary ticket responsible user is updated
$Self->IsDeeply(
    $PrimaryLastHistoryEntry->{Name},
    'PrimaryTicketAction: TicketResponsibleUpdate',
    "PrimaryTicket TicketResponsibleUpdate event - ",
);

# verify secondary ticket owner is updated
%SecondaryTicketData = $TicketObject->TicketGet(
    TicketID => $SecondaryTicketID,
    UserID   => 1,
);
$Self->IsDeeply(
    $SecondaryTicketData{Responsible},
    $TestUserLogin,
    "SecondaryTicket responsible updated - ",
);

# ------------------------------------------------------------ #
# test event TicketLockUpdate
# ------------------------------------------------------------ #

# lock Primary ticket
$Success = $TicketObject->TicketLockSet(
    Lock     => 'lock',
    TicketID => $PrimaryTicketID,
    UserID   => 1,
);
$Self->True(
    $Success,
    "TicketLockSet() PrimaryTicket is locked",
);

# get Primary ticket history
@PrimaryHistoryLines = $TicketObject->HistoryGet(
    TicketID => $PrimaryTicketID,
    UserID   => 1,
);
$PrimaryLastHistoryEntry = $PrimaryHistoryLines[-1];

# verify Primary ticket is locked
$Self->IsDeeply(
    $PrimaryLastHistoryEntry->{Name},
    'PrimaryTicketAction: TicketLockUpdate',
    "PrimaryTicket TicketLockUpdate event - ",
);

# verify secondary ticket is locked
%SecondaryTicketData = $TicketObject->TicketGet(
    TicketID => $SecondaryTicketID,
    UserID   => 1,
);
$Self->IsDeeply(
    $SecondaryTicketData{Lock},
    'lock',
    "SecondaryTicket lock updated - ",
);

# cleanup is done by RestoreDatabase

1;
