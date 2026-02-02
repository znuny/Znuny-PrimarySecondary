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

use Kernel::System::VariableCheck qw(:all);

use vars (qw($Self));

my $Selenium = $Kernel::OM->Get('Kernel::System::UnitTest::Selenium');

$Selenium->RunTest(
    sub {
        my $HelperObject = $Kernel::OM->Get('Kernel::System::UnitTest::Helper');

        my $TicketObject       = $Kernel::OM->Get('Kernel::System::Ticket');
        my $ArticleObject      = $Kernel::OM->Get('Kernel::System::Ticket::Article');
        my $QueueObject        = $Kernel::OM->Get('Kernel::System::Queue');
        my $DynamicFieldObject = $Kernel::OM->Get('Kernel::System::DynamicField');
        my $SalutationObject   = $Kernel::OM->Get('Kernel::System::Salutation');
        my $CustomerUserObject = $Kernel::OM->Get('Kernel::System::CustomerUser');
        my $ConfigObject       = $Kernel::OM->Get('Kernel::Config');
        my $UserObject         = $Kernel::OM->Get('Kernel::System::User');

        $HelperObject->ConfigSettingChange(
            Valid => 1,
            Key   => 'CheckMXRecord',
            Value => 0,
        );
        $HelperObject->ConfigSettingChange(
            Valid => 1,
            Key   => 'CheckEmailAddresses',
            Value => 0,
        );
        $HelperObject->ConfigSettingChange(
            Key   => 'SendmailModule',
            Value => 'Kernel::System::Email::Test',
        );
        $HelperObject->ConfigSettingChange(
            Valid => 1,
            Key   => 'PrimarySecondary::ForwardSecondary',
            Value => 1,
        );

        my $RandomID = $HelperObject->GetRandomID();

        # Create test salutation using rich text.
        my $SalutationText = "<strong>Test Bold ${RandomID} </strong>";
        my $SalutationID   = $SalutationObject->SalutationAdd(
            Name        => "New Salutation $RandomID",
            Text        => $SalutationText,
            ContentType => 'text/html',
            Comment     => 'some comment',
            ValidID     => 1,
            UserID      => 1,
        );
        $Self->True(
            $SalutationID,
            "SalutationID $SalutationID is created.",
        );

        # Create test queue.
        my $QueueName = "Salutation $RandomID";
        my $QueueID   = $QueueObject->QueueAdd(
            Name            => $QueueName,
            Group           => 'admin',
            ValidID         => 1,
            GroupID         => 1,
            SystemAddressID => 1,
            SalutationID    => $SalutationID,
            SignatureID     => 1,
            Comment         => 'Some comment',
            UserID          => 1

        );
        $Self->True(
            $QueueID,
            "QueueID $QueueID is created.",
        );

        # Assign answer templates to queue.
        for my $TemplateID ( 1 .. 2 ) {
            my $Success = $QueueObject->QueueStandardTemplateMemberAdd(
                QueueID            => $QueueID,
                StandardTemplateID => $TemplateID,
                Active             => 1,
                UserID             => 1,
            );
            $Self->True(
                $Success,
                "TemplateID '$TemplateID' is assigned to QueueID '$QueueID'.",
            );
        }

        my $TestCustomerUserLogin = $HelperObject->TestCustomerUserCreate();
        my %TestCustomerUser      = $CustomerUserObject->CustomerUserDataGet(
            User => $TestCustomerUserLogin,
        );

        # Create primary ticket.
        my $PrimaryTicketNumber = $TicketObject->TicketCreateNumber();
        my $PrimaryTicketID     = $TicketObject->TicketCreate(
            TN           => $PrimaryTicketNumber,
            Title        => "Primary $RandomID",
            QueueID      => $QueueID,
            Lock         => 'unlock',
            Priority     => '3 normal',
            State        => 'new',
            CustomerNo   => $TestCustomerUserLogin,
            CustomerUser => $TestCustomerUserLogin,
            OwnerID      => 1,
            UserID       => 1,
        );
        $Self->True(
            $PrimaryTicketID,
            "TicketID $PrimaryTicketID is created (primary).",
        );

        my $ArticleID = $ArticleObject->BackendForChannel( ChannelName => 'Phone' )->ArticleCreate(
            TicketID             => $PrimaryTicketID,
            IsVisibleForCustomer => 1,
            SenderType           => 'agent',
            Subject              => 'Primary Article',
            Body                 => 'Unit test PrimaryTicket',
            ContentType          => 'text/plain; charset=ISO-8859-15',
            HistoryType          => 'PhoneCallCustomer',
            HistoryComment       => 'Unit test article',
            UserID               => 1,
        );
        $Self->True(
            $ArticleID,
            "ArticleID $ArticleID is created.",
        );

        # Get Primary/Secondary dynamic field data.
        my $PrimarySecondaryDynamicField     = $ConfigObject->Get('PrimarySecondary::DynamicField');
        my $PrimarySecondaryDynamicFieldData = $DynamicFieldObject->DynamicFieldGet(
            Name => $PrimarySecondaryDynamicField,
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
            "TicketID $PrimaryTicketID, DynamicField '$PrimarySecondaryDynamicField' is updated as PrimaryTicket.",
        );

        # Create secondary ticket.
        my $SecondaryTicketID = $TicketObject->TicketCreate(
            Title        => "Secondary $RandomID",
            QueueID      => $QueueID,
            Lock         => 'unlock',
            Priority     => '3 normal',
            State        => 'new',
            CustomerID   => $TestCustomerUserLogin,
            CustomerUser => $TestCustomerUserLogin,
            OwnerID      => 1,
            UserID       => 1,
        );
        $Self->True(
            $SecondaryTicketID,
            "TicketID $SecondaryTicketID is created (secondary).",
        );

        # Set test ticket to secondary.
        $Success = $DynamicFieldBackendObject->ValueSet(
            DynamicFieldConfig => $DynamicField,
            ObjectID           => $SecondaryTicketID,
            Value              => "SecondaryOf:$PrimaryTicketNumber",
            UserID             => 1,
        );
        $Self->True(
            $Success,
            "TicketID $SecondaryTicketID, DynamicField '$PrimarySecondaryDynamicField' is updated as SecondaryTicket.",
        );

        # Create test user.
        my $TestUserLogin = $HelperObject->TestUserCreate(
            Groups => [ 'admin', 'users' ],
        );

        # Get test user ID.
        my $TestUserID = $UserObject->UserLookup(
            UserLogin => $TestUserLogin,
        );

        # Login as test user.
        $Selenium->Login(
            Type     => 'Agent',
            User     => $TestUserLogin,
            Password => $TestUserLogin,
        );

        my $ScriptAlias = $ConfigObject->Get('ScriptAlias');

        # Send article via backend to avoid UI dependencies.
        my $EmailBackendObject = $ArticleObject->BackendForChannel( ChannelName => 'Email' );
        my $SentArticleID      = $EmailBackendObject->ArticleSend(
            TicketID             => $PrimaryTicketID,
            SenderType           => 'agent',
            IsVisibleForCustomer => 1,
            From                 => 'Some Agent <agent@example.com>',
            To                   => $TestCustomerUser{UserEmail},
            Subject              => 'Primary Article',
            Body                 => $SalutationText,
            Charset              => 'utf-8',
            MimeType             => 'text/html',
            Loop                 => 0,
            HistoryType          => 'SendAnswer',
            HistoryComment       => 'Unit test send answer',
            UserID               => 1,
        );
        $Self->True(
            $SentArticleID,
            "Primary email article sent (ArticleID $SentArticleID).",
        );

        # Force email queue handling for this article.
        my $MailQueueObject = $Kernel::OM->Get('Kernel::System::MailQueue');
        if ( my $Item = $MailQueueObject->Get( ArticleID => $SentArticleID ) ) {
            $MailQueueObject->Send( %{$Item} );
        }

        my @SecondaryArticles = $ArticleObject->ArticleList(
            TicketID => $SecondaryTicketID,
        );
        $Self->True(
            scalar @SecondaryArticles,
            "Secondary ticket has articles.",
        );

        my $SecondaryArticleID     = $SecondaryArticles[-1]->{ArticleID};
        my $SecondaryBackendObject = $ArticleObject->BackendForArticle(
            TicketID  => $SecondaryTicketID,
            ArticleID => $SecondaryArticleID,
        );
        my %SecondaryArticle = $SecondaryBackendObject->ArticleGet(
            TicketID  => $SecondaryTicketID,
            ArticleID => $SecondaryArticleID,
        );

        my $SecondaryHTML;
        my %AttachmentIndex = $SecondaryBackendObject->ArticleAttachmentIndex(
            ArticleID => $SecondaryArticleID,
        );
        FILEID:
        for my $FileID ( sort keys %AttachmentIndex ) {
            next FILEID if !$FileID;
            next FILEID if $AttachmentIndex{$FileID}->{ContentType} !~ m{text/html}i;
            my %Attachment = $SecondaryBackendObject->ArticleAttachment(
                ArticleID => $SecondaryArticleID,
                FileID    => $FileID,
            );
            $SecondaryHTML = $Attachment{Content};
            last FILEID;
        }

        my $ContentToCheck = defined $SecondaryHTML && length $SecondaryHTML
            ? $SecondaryHTML
            : ( $SecondaryArticle{Body} || '' );

        # Check if secondary ticket article has salutation in rich text format. See bug#14983.
        $Self->True(
            index( $ContentToCheck, $SalutationText ) > -1,
            "Secondary article contains rich text '$SalutationText'. ",
        );

        # Cleanup.
        my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

        # Delete test created tickets.
        for my $TicketID ( $PrimaryTicketID, $SecondaryTicketID ) {
            $Success = $TicketObject->TicketDelete(
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
                "TicketID $TicketID is deleted."
            );
        }

        $Success = $DBObject->Do(
            SQL  => "DELETE FROM queue_standard_template WHERE queue_id = ?",
            Bind => [ \$QueueID, ],
        );
        $Self->True(
            $Success,
            "Standard_template_queue relation for QueueID $QueueID is deleted."
        );

        # Delete queues.
        $Success = $DBObject->Do(
            SQL  => "DELETE FROM queue WHERE id = ?",
            Bind => [ \$QueueID, ],
        );
        $Self->True(
            $Success,
            "QueueID $QueueID is deleted.",
        );

        # Delete salutation.
        $Success = $DBObject->Do(
            SQL  => "DELETE FROM salutation WHERE id = ?",
            Bind => [ \$SalutationID, ],
        );
        $Self->True(
            $Success,
            "SalutationID $SalutationID is deleted.",
        );

    }
);

1;
