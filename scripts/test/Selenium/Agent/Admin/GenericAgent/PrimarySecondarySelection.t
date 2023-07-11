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

        my $Helper = $Kernel::OM->Get('Kernel::System::UnitTest::Helper');

        # Enable the UnsetPrimarySecondary config.
        $Helper->ConfigSettingChange(
            Key   => 'PrimarySecondary::UnsetPrimarySecondary',
            Value => 1,
        );

        # Create test user and log in.
        my $TestUserLogin = $Helper->TestUserCreate(
            Groups => [ 'admin', 'users' ],
        ) || die "Did not get test user";

        $Selenium->Login(
            Type     => 'Agent',
            User     => $TestUserLogin,
            Password => $TestUserLogin,
        );

        my $ScriptAlias = $Kernel::OM->Get('Kernel::Config')->Get('ScriptAlias');

        # Navigate to AdminGenericAgent screen for new job adding.
        $Selenium->VerifiedGet("${ScriptAlias}index.pl?Action=AdminGenericAgent;Subaction=Update");

        $Selenium->WaitFor( JavaScript => "return typeof(\$) === 'function';" );

        # Expand appropriate widget.
        $Selenium->execute_script(
            "\$('.WidgetSimple.Collapsed:contains(\"Update/Add Ticket Attributes\") .WidgetAction.Toggle a').trigger('click');"
        );
        $Selenium->WaitFor(
            JavaScript => "return \$('.WidgetSimple.Expanded').length;"
        );

        # Add appropriate dynamic field.
        $Selenium->execute_script(
            "\$('#AddNewDynamicFields').val('DynamicField_PrimarySecondary').trigger('redraw.InputField').trigger('change');"
        );
        $Selenium->WaitFor(
            JavaScript => "return \$('#SelectedNewDynamicFields #DynamicField_PrimarySecondary').length;"
        );

 # Verify possible PrimarySecondary values 'UnsetPrimary' and 'UnsetSecondary' in 'Update/Add Ticket Attributes' widget.
 # See bug#14778 (https://bugs.otrs.org/show_bug.cgi?id=14778).
        for my $Option (qw(UnsetPrimary UnsetSecondary)) {
            $Self->True(
                $Selenium->execute_script("return \$('#DynamicField_PrimarySecondary option[value=$Option]').length;"),
                "PrimarySecondary option '$Option' is available."
            );
        }

        # Disable the UnsetPrimarySecondary config.
        $Helper->ConfigSettingChange(
            Key   => 'PrimarySecondary::UnsetPrimarySecondary',
            Value => 0,
        );

        # Refresh screen.
        $Selenium->VerifiedRefresh();

        # Expand appropriate widget.
        $Selenium->execute_script(
            "\$('.WidgetSimple.Collapsed:contains(\"Update/Add Ticket Attributes\") .WidgetAction.Toggle a').trigger('click');"
        );
        $Selenium->WaitFor(
            JavaScript => "return \$('.WidgetSimple.Expanded').length;"
        );

        # Add appropriate dynamic field.
        $Selenium->execute_script(
            "\$('#AddNewDynamicFields').val('DynamicField_PrimarySecondary').trigger('redraw.InputField').trigger('change');"
        );
        $Selenium->WaitFor(
            JavaScript => "return \$('#SelectedNewDynamicFields #DynamicField_PrimarySecondary').length;"
        );

        # Verify possible PrimarySecondary values 'UnsetPrimary' and 'UnsetSecondary' are not available
        #   in 'Update/Add Ticket Attributes' widget.
        for my $Option (qw(UnsetPrimary UnsetSecondary)) {
            $Self->False(
                $Selenium->execute_script("return \$('#DynamicField_PrimarySecondary option[value=$Option]').length;"),
                "PrimarySecondary option '$Option' is not available."
            );
        }
    }
);

1;
