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

my $Selenium = $Kernel::OM->Get('Kernel::System::UnitTest::Selenium');

$Selenium->RunTest(
    sub {

        my $HelperObject = $Kernel::OM->Get('Kernel::System::UnitTest::Helper');
        my $TicketObject = $Kernel::OM->Get('Kernel::System::Ticket');
        my $UserObject   = $Kernel::OM->Get('Kernel::System::User');
        my $ConfigObject = $Kernel::OM->Get('Kernel::Config');
        my $CacheObject  = $Kernel::OM->Get('Kernel::System::Cache');

        # Enable the advanced PrimarySecondary.
        $HelperObject->ConfigSettingChange(
            Key   => 'PrimarySecondary::AdvancedEnabled',
            Value => 1,
        );

        # Enable change the PrimarySecondary state of a ticket.
        $HelperObject->ConfigSettingChange(
            Key   => 'PrimarySecondary::UpdatePrimarySecondary',
            Value => 1,
        );

        # Do not send emails.
        $HelperObject->ConfigSettingChange(
            Key   => 'SendmailModule',
            Value => 'Kernel::System::Email::Test',
        );

        # Create test user.
        my $TestUserLogin = $HelperObject->TestUserCreate(
            Groups => [ 'admin', 'users' ],
        ) || die "Did not get test user";

        # Get test user ID.
        my $TestUserID = $UserObject->UserLookup(
            UserLogin => $TestUserLogin,
        );

        # Create three test tickets.
        my @TicketIDs;
        my @TicketNumbers;
        my $TicketTitle = 'PrimarySecondary ' . $HelperObject->GetRandomID();
        for my $TicketCreate ( 1 .. 3 ) {
            my $TicketNumber = $TicketObject->TicketCreateNumber();
            my $TicketID     = $TicketObject->TicketCreate(
                TN           => $TicketNumber,
                Title        => $TicketTitle,
                Queue        => 'Raw',
                Lock         => 'unlock',
                Priority     => '3 normal',
                StateID      => 1,
                TypeID       => 1,
                CustomerID   => 'SeleniumCustomer',
                CustomerUser => 'customer@example.com',
                OwnerID      => $TestUserID,
                UserID       => $TestUserID,
            );
            $Self->True(
                $TicketID,
                "Ticket ID $TicketID - created",
            );

            push @TicketIDs,     $TicketID;
            push @TicketNumbers, $TicketNumber;
        }

        # Login as test user.
        $Selenium->Login(
            Type     => 'Agent',
            User     => $TestUserLogin,
            Password => $TestUserLogin,
        );

        my $ScriptAlias = $ConfigObject->Get('ScriptAlias');

        # Navigate to AgentTicketSearch.
        $Selenium->VerifiedGet("${ScriptAlias}index.pl?Action=AgentTicketSearch");

        # Wait until form has loaded, if necessary.
        $Selenium->WaitFor( JavaScript => "return typeof(\$) === 'function' && \$('#Attribute').length;" );

        # Search test created tickets by title.
        $Selenium->execute_script("\$('#Attribute').val('Title').trigger('redraw.InputField').trigger('change');");

        $Selenium->find_element( "Title", 'name' )->send_keys($TicketTitle);
        $Selenium->find_element("//button[\@id='SearchFormSubmit'][\@value='Search']")->VerifiedClick();

        $Selenium->WaitFor(
            JavaScript => "return typeof(\$) === 'function' && \$('.Checkbox[value=$TicketIDs[0]]').length;"
        );

        # Select first test created ticket.
        $Selenium->execute_script("\$('.Checkbox[value=$TicketIDs[0]]').click();");
        $Selenium->WaitFor(
            JavaScript => "return typeof(\$) === 'function' && \$('.Checkbox[value=$TicketIDs[0]]:checked').length;"
        );

        # Click on bulk and switch screen.
        $Selenium->find_element( "Bulk", 'link_text' )->click();

        $Selenium->WaitFor( WindowCount => 2 );
        my $Handles = $Selenium->get_window_handles();
        $Selenium->switch_to_window( $Handles->[1] );

        # Wait until popup is completely loaded.
        $Selenium->WaitFor(
            JavaScript =>
                'return typeof(Core) == "object" && typeof(Core.App) == "object" && Core.App.PageLoadComplete;',
        );

        $Selenium->execute_script(
            "\$('#submitRichText')[0].scrollIntoView(true);",
        );

        $Selenium->WaitFor(
            JavaScript =>
                "return typeof(\$) === 'function' && \$('#DynamicField_PrimarySecondary').length && \$('#submitRichText').length;"
        );

        # Set test ticket as primary ticket.
        $Selenium->execute_script(
            "\$('#DynamicField_PrimarySecondary').val('Primary').trigger('redraw.InputField').trigger('change');"
        );
        $Selenium->find_element( "#submitRichText", 'css' )->click();

        $Selenium->switch_to_window( $Handles->[0] );
        $Selenium->WaitFor( WindowCount => 1 );

        # Wait until popup is completely loaded.
        $Selenium->VerifiedRefresh();

        # Select second and third test created ticket.
        $Selenium->WaitFor(
            JavaScript => "return typeof(\$) === 'function' && \$('.Checkbox[value=$TicketIDs[1]]').length;"
        );
        $Selenium->execute_script("\$('.Checkbox[value=$TicketIDs[1]]').click();");
        $Selenium->WaitFor(
            JavaScript => "return typeof(\$) === 'function' && \$('input[value=$TicketIDs[1]]:checked').length;"
        );

        $Selenium->WaitFor(
            JavaScript => "return typeof(\$) === 'function' && \$('.Checkbox[value=$TicketIDs[2]]').length;"
        );
        $Selenium->execute_script("\$('.Checkbox[value=$TicketIDs[2]]').click();");
        $Selenium->WaitFor(
            JavaScript => "return typeof(\$) === 'function' && \$('input[value=$TicketIDs[2]]:checked').length;"
        );

        # Click on bulk and switch screen.
        $Selenium->find_element( "Bulk", 'link_text' )->click();

        $Selenium->WaitFor( WindowCount => 2 );
        $Handles = $Selenium->get_window_handles();
        $Selenium->switch_to_window( $Handles->[1] );

        # Wait until popup is completely loaded.
        $Selenium->WaitFor(
            JavaScript =>
                'return typeof(Core) == "object" && typeof(Core.App) == "object" && Core.App.PageLoadComplete;',
        );

        $Selenium->WaitFor(
            JavaScript =>
                "return typeof(\$) === 'function' && \$('#DynamicField_PrimarySecondary').length && \$('#submitRichText').length;"
        );

        # Set test tickets as secondary tickets.
        $Selenium->execute_script(
            "\$('#DynamicField_PrimarySecondary').val('SecondaryOf:$TicketNumbers[0]').trigger('redraw.InputField').trigger('change');"
        );

        $Selenium->find_element( "#submitRichText", 'css' )->click();

        $Selenium->switch_to_window( $Handles->[0] );
        $Selenium->WaitFor( WindowCount => 1 );

        # Navigate to primary ticket zoom view.
        $Selenium->VerifiedGet("${ScriptAlias}index.pl?Action=AgentTicketZoom;TicketID=$TicketIDs[0]");

        # Verify Primary/Secondary ticket link.
        $Self->True(
            index( $Selenium->get_page_source(), $TicketNumbers[1] ) > -1,
            "Secondary ticket number: $TicketNumbers[1] - found",
        );
        $Self->True(
            index( $Selenium->get_page_source(), $TicketNumbers[2] ) > -1,
            "Secondary ticket number: $TicketNumbers[2] - found",
        );

        # Delete created test tickets.
        for my $TicketID (@TicketIDs) {
            my $Success = $TicketObject->TicketDelete(
                TicketID => $TicketID,
                UserID   => 1,
            );
            $Self->True(
                $Success,
                "Ticket ID $TicketID - deleted"
            );
        }

        # Make sure the cache is correct.
        $CacheObject->CleanUp(
            Type => 'Ticket',
        );
    }
);

1;
