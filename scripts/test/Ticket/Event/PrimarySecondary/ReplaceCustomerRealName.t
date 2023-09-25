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

my $ConfigObject = $Kernel::OM->Get('Kernel::Config');

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
$ConfigObject->Set(
    Key   => 'SendmailModule',
    Value => 'Kernel::System::Email::DoNotSendEmail',
);

my $RandomID = $HelperObject->GetRandomID();

my $DynamicFieldObject               = $Kernel::OM->Get('Kernel::System::DynamicField');
my $PrimarySecondaryDynamicField     = $ConfigObject->Get('PrimarySecondary::DynamicField');
my $PrimarySecondaryDynamicFieldData = $DynamicFieldObject->DynamicFieldGet(
    Name => $PrimarySecondaryDynamicField,
);

# Create new user.
my $TestUserLogin = $HelperObject->TestUserCreate(
    Groups   => [ 'admin', 'users' ],
    Language => 'en'
);
$Self->True(
    $TestUserLogin,
    "UserAdd() $TestUserLogin",
);

# Create new customer users.
my $TestCustomerUserLogin1 = $HelperObject->TestCustomerUserCreate(
    Language => 'en',
);
$Self->True(
    $TestCustomerUserLogin1,
    "CustomerUserAdd() $TestCustomerUserLogin1",
);

my $TestCustomerUserLogin2 = $HelperObject->TestCustomerUserCreate(
    Language => 'en',
);
$Self->True(
    $TestCustomerUserLogin2,
    "CustomerUserAdd() $TestCustomerUserLogin2",
);

my $TicketObject = $Kernel::OM->Get('Kernel::System::Ticket');

# Create first test ticket.
my $PrimaryTicketNumber = $TicketObject->TicketCreateNumber();
my $PrimaryTicketID     = $TicketObject->TicketCreate(
    TN           => $PrimaryTicketNumber,
    Title        => 'Primary unit test ticket ' . $RandomID,
    Queue        => 'Raw',
    Lock         => 'unlock',
    Priority     => '3 normal',
    State        => 'new',
    CustomerNo   => $TestCustomerUserLogin1,
    CustomerUser => $TestCustomerUserLogin1,
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

# Create article for test ticket.
my $ArticleID = $EmailBackendObject->ArticleCreate(
    TicketID             => $PrimaryTicketID,
    From                 => 'root@localhost',
    To                   => 'test@examples.com',
    IsVisibleForCustomer => 1,
    SenderType           => 'agent',
    Subject              => 'Primary Article',
    Body                 => "Unit test PrimaryTicket $TestCustomerUserLogin1 $TestCustomerUserLogin1",
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

my $DynamicFieldBackendObject = $Kernel::OM->Get('Kernel::System::DynamicField::Backend');

# Set test ticket as primary ticket.
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

# Create second test ticket.
my $SecondaryTicketNumber = $TicketObject->TicketCreateNumber();
my $SecondaryTicketID     = $TicketObject->TicketCreate(
    TN           => $SecondaryTicketNumber,
    Title        => 'Secondary unit test ticket ' . $RandomID,
    Queue        => 'Raw',
    Lock         => 'unlock',
    Priority     => '3 normal',
    State        => 'new',
    CustomerID   => $TestCustomerUserLogin2,
    CustomerUser => $TestCustomerUserLogin2,
    OwnerID      => 1,
    UserID       => 1,
);
$Self->True(
    $SecondaryTicketID,
    "TicketCreate() Ticket ID $SecondaryTicketID",
);

# Set test ticket as secondary of Primary ticket.
$Success = $DynamicFieldBackendObject->ValueSet(
    DynamicFieldConfig => $DynamicField,
    ObjectID           => $SecondaryTicketID,
    Value              => "SecondaryOf:$PrimaryTicketNumber",
    UserID             => 1,
);
$Self->True(
    $Success,
    "ValueSet() Ticket ID $SecondaryTicketID DynamicField $PrimarySecondaryDynamicField updated as SecondaryTicket",
);

my $EventObject = $Kernel::OM->Get('Kernel::System::Ticket::Event::PrimarySecondary');

my @Tests = (
    {
        Name           => 'Do not replace',
        EffectiveValue => {
            Email => 0,
        },
        Match => "$TestCustomerUserLogin1 $TestCustomerUserLogin1",
    },
    {
        Name           => 'Customer replace',
        EffectiveValue => {
            Email => 1,
        },
        Match => "$TestCustomerUserLogin2 $TestCustomerUserLogin2",
    },
);

TEST:
for my $Test (@Tests) {
    $ConfigObject->Set(
        Key   => 'ReplaceCustomerRealNameOnSecondaryArticleCommunicationChannels',
        Value => $Test->{EffectiveValue},
    );
    my $Success = $EventObject->Run(
        Event => 'ArticleSend',
        Data  => {
            TicketID => $PrimaryTicketID,
        },
        Config => {},
        UserID => 1,
    );
    $Self->True(
        $Success,
        "$Test->{Name} - ArticleSend event executed correctly",
    );

    my @Articles = $ArticleObject->ArticleList(
        TicketID => $SecondaryTicketID,
    );

    my $ArticleBackendObject = $ArticleObject->BackendForArticle(
        TicketID  => $Articles[-1]->{TicketID},
        ArticleID => $Articles[-1]->{ArticleID},
    );

    my %Article = $ArticleBackendObject->ArticleGet(
        TicketID  => $Articles[-1]->{TicketID},
        ArticleID => $Articles[-1]->{ArticleID},
    );

    my $MatchSuccess = $Article{Body} =~ m{$Test->{Match}} // 0;

    $Self->True(
        $MatchSuccess,
        "$Test->{Name} - New article body matched customer real name: '$Test->{Match}'",
    );
}

1;
