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

# Create local function for wait on AJAX update.
my $WaitForAJAX = sub {

    Time::HiRes::sleep(0.2);

    $Selenium->WaitFor(
        JavaScript =>
            'return typeof($) === "function" && !$("span.AJAXLoader:visible").length;'
    );
};

$Selenium->RunTest(
    sub {

        my $Helper = $Kernel::OM->Get('Kernel::System::UnitTest::Helper');

        # Enable the advanced PrimarySecondary.
        $Helper->ConfigSettingChange(
            Key   => 'PrimarySecondary::AdvancedEnabled',
            Value => 1,
        );

        # Do not check RichText.
        $Helper->ConfigSettingChange(
            Key   => 'Frontend::RichText',
            Value => 0,
        );

        # Do not check service and type.
        $Helper->ConfigSettingChange(
            Key   => 'Ticket::Service',
            Value => 0
        );
        $Helper->ConfigSettingChange(
            Key   => 'Ticket::Type',
            Value => 0,
        );
        $Helper->ConfigSettingChange(
            Valid => 1,
            Key   => 'CheckEmailAddresses',
            Value => 0,
        );

        # Do not send emails.
        $Helper->ConfigSettingChange(
            Key   => 'SendmailModule',
            Value => 'Kernel::System::Email::Test',
        );

        # Add test customer for testing.
        my $TestCustomerLoginPhone = $Helper->TestCustomerUserCreate();

        # Create test user and login.
        my $TestUserLogin = $Helper->TestUserCreate(
            Groups => [ 'admin', 'users' ],
        ) || die "Did not get test user";

        $Selenium->Login(
            Type     => 'Agent',
            User     => $TestUserLogin,
            Password => $TestUserLogin,
        );

        my $ScriptAlias = $Kernel::OM->Get('Kernel::Config')->Get('ScriptAlias');

        # Navigate to AgentTicketPhone screen.
        $Selenium->VerifiedGet("${ScriptAlias}index.pl?Action=AgentTicketPhone");

        $Selenium->WaitForjQueryEventBound(
            CSSSelector => '#Dest',
            Event       => 'change',
        );

        $Selenium->execute_script("\$('#Dest').val('2||Raw').trigger('redraw.InputField').trigger('change');");

        # Wait for AJAX to finish.
        $WaitForAJAX->();

        my $PrimaryTicketSubject = "Primary Ticket";
        $Selenium->find_element( "#FromCustomer", 'css' )->send_keys($TestCustomerLoginPhone);
        $Selenium->WaitFor( JavaScript => 'return typeof($) === "function" && $("li.ui-menu-item:visible").length;' );

        $Selenium->execute_script(
            "\$('li.ui-menu-item:nth-child(1) a').trigger('click');",
        );

        # Wait for AJAX to finish.
        $WaitForAJAX->();

        $Selenium->find_element( "#Subject",  'css' )->send_keys($PrimaryTicketSubject);
        $Selenium->find_element( "#RichText", 'css' )->send_keys('Selenium body test');
        $Selenium->execute_script(
            "\$('#DynamicField_PrimarySecondary').val('Primary').trigger('redraw.InputField').trigger('change');"
        );

        # Wait for AJAX to finish.
        $WaitForAJAX->();

        $Selenium->execute_script(
            "\$('#submitRichText')[0].scrollIntoView(true);",
        );
        $Self->True(
            $Selenium->execute_script(
                "return \$('#submitRichText').length;"
            ),
            "Element '#submitRichText' is found in the screen"
        );
        $Selenium->find_element( "#submitRichText", 'css' )->VerifiedClick();

        my $TicketObject = $Kernel::OM->Get('Kernel::System::Ticket');

        # Get primary test phone ticket data.
        my ( $PrimaryTicketID, $PrimaryTicketNumber ) = $TicketObject->TicketSearch(
            Result            => 'HASH',
            Limit             => 1,
            CustomerUserLogin => $TestCustomerLoginPhone,
            UserID            => 1,
        );

        $Self->True(
            $PrimaryTicketID,
            "Primary TicketID - $PrimaryTicketID",
        );
        $Self->True(
            $PrimaryTicketNumber,
            "Primary TicketNumber - $PrimaryTicketNumber",
        );

        # Add new test customer for testing.
        my $TestCustomerLoginsEmail = $Helper->TestCustomerUserCreate();

        # Navigate to AgentTicketEmail screen.
        $Selenium->VerifiedGet("${ScriptAlias}index.pl?Action=AgentTicketEmail");

        $Selenium->WaitForjQueryEventBound(
            CSSSelector => '#Dest',
            Event       => 'change',
        );

        # Create secondary test email ticket.
        $Selenium->execute_script("\$('#Dest').val('2||Raw').trigger('redraw.InputField').trigger('change');");

        # Wait for AJAX to finish.
        $WaitForAJAX->();

        $Selenium->find_element( "#ToCustomer", 'css' )->send_keys($TestCustomerLoginsEmail);
        $Selenium->WaitFor( JavaScript => 'return typeof($) === "function" && $("li.ui-menu-item:visible").length;' );
        $Selenium->execute_script(
            "\$('li.ui-menu-item:nth-child(1) a').trigger('click');",
        );

        # Wait for AJAX to finish.
        $WaitForAJAX->();

        $Selenium->find_element( "#Subject",  'css' )->send_keys('Secondary Ticket');
        $Selenium->find_element( "#RichText", 'css' )->send_keys('Selenium body test');
        $Selenium->execute_script(
            "\$('#DynamicField_PrimarySecondary').val('SecondaryOf:$PrimaryTicketNumber').trigger('redraw.InputField').trigger('change');"
        );

        # Wait for AJAX to finish.
        $WaitForAJAX->();

        $Selenium->execute_script(
            "\$('#submitRichText')[0].scrollIntoView(true);",
        );
        $Self->True(
            $Selenium->execute_script(
                "return \$('#submitRichText').length;"
            ),
            "Element '#submitRichText' is found in the screen"
        );
        $Selenium->find_element( "#submitRichText", 'css' )->VerifiedClick();

        # get secondary test email ticket data
        my ( $SecondaryTicketID, $SecondaryTicketNumber ) = $TicketObject->TicketSearch(
            Result            => 'HASH',
            Limit             => 1,
            CustomerUserLogin => $TestCustomerLoginsEmail,
            UserID            => 1,
        );

        $Self->True(
            $SecondaryTicketID,
            "Secondary TicketID - $SecondaryTicketID",
        );
        $Self->True(
            $SecondaryTicketNumber,
            "Secondary TicketNumber - $SecondaryTicketNumber",
        );

        # Navigate to ticket zoom page of created primary test ticket.
        $Selenium->VerifiedGet("${ScriptAlias}index.pl?Action=AgentTicketZoom;TicketID=$PrimaryTicketID");

        # Verify Primary/Secondary ticket link.
        $Self->True(
            index( $Selenium->get_page_source(), $SecondaryTicketNumber ) > -1,
            "Secondary ticket number: $SecondaryTicketNumber - found",
        );

        # Navigate to history view of created primary test ticket.
        $Selenium->VerifiedGet("${ScriptAlias}index.pl?Action=AgentTicketHistory;TicketID=$PrimaryTicketID");

        # Verify dynamic field primary ticket update.
        $Self->True(
            index( $Selenium->get_page_source(), 'Changed dynamic field PrimarySecondary from "" to "Primary".' ) > -1,
            "Primary dynamic field update value - found",
        );

        # Navigate to ticket zoom page of created secondary test ticket.
        $Selenium->VerifiedGet("${ScriptAlias}index.pl?Action=AgentTicketZoom;TicketID=$SecondaryTicketID");

        # Verify secondary-primary ticket link
        $Self->True(
            index( $Selenium->get_page_source(), $PrimaryTicketNumber ) > -1,
            "Primary ticket number: $PrimaryTicketNumber - found",
        );

        # Navigate to history view of created secondary test ticket.
        $Selenium->VerifiedGet("${ScriptAlias}index.pl?Action=AgentTicketHistory;TicketID=$SecondaryTicketID");

        # Verify dynamic field secondary ticket update.
        $Self->True(
            index( $Selenium->get_page_source(), 'Changed dynamic field PrimarySecondary from "" to "SecondaryOf:' )
                > -1,
            "Secondary dynamic field update value - found",
        );

        # Delete test tickets.
        for my $TicketID ( $PrimaryTicketID, $SecondaryTicketID ) {
            my $Success = $TicketObject->TicketDelete(
                TicketID => $TicketID,
                UserID   => 1,
            );

            # Ticket deletion could fail if apache still writes to ticket history. Try again in this case.
            if ( !$Success ) {
                sleep 3;
                $Success = $TicketObject->TicketDelete(
                    TicketID => $TicketID,
                    UserID   => 1,
                );
            }

            $Self->True(
                $Success,
                "Ticket ID $TicketID - deleted"
            );
        }

        # Make sure the cache is correct.
        $Kernel::OM->Get('Kernel::System::Cache')->CleanUp(
            Type => 'Ticket',
        );
    }
);

1;
