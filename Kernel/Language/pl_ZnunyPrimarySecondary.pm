# --
# Copyright (C) 2021 Znuny GmbH, https://znuny.org/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Language::pl_ZnunyPrimarySecondary;

use strict;
use warnings;
use utf8;

sub Data {
    my $Self = shift;

    # TT Template: Kernel/Output/HTML/Templates/Standard/AgentTicketPrimarySecondary.tt
    $Self->{Translation}->{'Manage Primary/Secondary status for %s%s%s'} = 'Zarządzaj statusem Nadrzędny/Podrzędny zgłoszenia %s%s%s';

    # Perl Module: Kernel/Modules/AgentTicketPrimarySecondary.pm
    $Self->{Translation}->{'New Primary Ticket'} = 'Nowe Zgłoszenie Nadrzędne';
    $Self->{Translation}->{'Unset Primary Ticket'} = 'Usuń Nadrzędność Zgłoszenia';
    $Self->{Translation}->{'Unset Secondary Ticket'} = 'Usuń Podrzędność Zgłoszenia';
    $Self->{Translation}->{'Secondary of %s%s%s: %s'} = 'Podrzędny do %s%s%s: %s';

    # Perl Module: Kernel/Output/HTML/TicketBulk/PrimarySecondary.pm
    $Self->{Translation}->{'Unset Primary Tickets'} = 'Usuń Nadrzędność Zgłoszeń';
    $Self->{Translation}->{'Unset Secondary Tickets'} = 'Usuń Podrzędność Zgłoszeń';

    # Perl Module: Kernel/System/DynamicField/Driver/PrimarySecondary.pm
    $Self->{Translation}->{'Primary'} = 'Nadrzędny';
    $Self->{Translation}->{'Secondary of %s%s%s'} = 'Podrzędny do %s%s%s';
    $Self->{Translation}->{'Primary Ticket'} = 'Zgłoszenie Nadrzędne';

    # SysConfig
    $Self->{Translation}->{'All primary tickets'} = 'Wszystkie zgłoszenia nadrzędne';
    $Self->{Translation}->{'All secondary tickets'} = 'Wszystkie zgłoszenia podrzędne';
    $Self->{Translation}->{'Allows adding notes in the ticket PrimarySecondary screen of a zoomed ticket in the agent interface.'} =
        'Pozwala na dodawanie notatek w oknie Nadrzędny/Podrzędny w widoku szczegółów zgłoszenia interfejsu agenta.';
    $Self->{Translation}->{'Change the PrimarySecondary state of the ticket.'} = 'Zmień status Nadrzędny/Podrzędny zgłoszenia.';
    $Self->{Translation}->{'Defines dynamic field name for primary ticket feature.'} = 'Określa nazwę pola dynamicznego do funkcjonalności zgłoszeń nadrzędnych.';
    $Self->{Translation}->{'Defines if a ticket lock is required in the ticket PrimarySecondary screen of a zoomed ticket in the agent interface (if the ticket isn\'t locked yet, the ticket gets locked and the current agent will be set automatically as its owner).'} =
        'Określa czy jest wymagana blokada zgłoszenia w oknie Nadrzędny/Podrzędny w szczegółach zgłoszenia interfejsu agenta (jeśli zgłoszenie nie jest jeszcze zablokowane, zostaje zablokowane a bieżący agent staje się jego właścicielem).';
    $Self->{Translation}->{'Defines if the PrimarySecondary note is visible for the customer by default.'} =
        'Określa czy notatka Nadrzędny/Podrzędny jest domyślnie widoczna dla klienta.';
    $Self->{Translation}->{'Defines the default next state of a ticket after adding a note, in the ticket PrimarySecondary screen of a zoomed ticket in the agent interface.'} =
        'Określa domyślny, następny stan zgłoszenia po dodaniu notatki w oknie Nadrzędny/Podrzędny z poziomu szczegółów zgłoszenia w interfejsie agenta.';
    $Self->{Translation}->{'Defines the default ticket priority in the ticket PrimarySecondary screen of a zoomed ticket in the agent interface.'} =
        'Określa domyślny, następny priorytet zgłoszenia po dodaniu notatki w oknie Nadrzędny/Podrzędny z poziomu szczegółów zgłoszenia w interfejsie agenta.';
    $Self->{Translation}->{'Defines the history comment for the ticket PrimarySecondary screen action, which gets used for ticket history in the agent interface.'} =
        'Określa komentarz w historii zgłoszenia po wykonaniu akcji w oknie Nadrzędny/Podrzędny, który zostanie użyty w interfejsie agenta.';
    $Self->{Translation}->{'Defines the history type for the ticket PrimarySecondary screen action, which gets used for ticket history in the agent interface.'} =
        'Określa typ historii zgłoszenia po wykonaniu akcji w oknie Nadrzędny/Podrzędny, który zostanie użyty w historii zgłoszenia w interfejsie agenta.';
    $Self->{Translation}->{'Defines the next state of a ticket after adding a note, in the ticket PrimarySecondary screen of a zoomed ticket in the agent interface.'} =
        'Określa następny stan zgłoszenia po dodaniu notatki w oknie Nadrzędny/Podrzędny z poziomu szczegółów zgłoszenia w interfejsie agenta.';
    $Self->{Translation}->{'Enables the advanced PrimarySecondary part of the feature.'} = 'Włącza dodatkowe zaawansowane funkcje Nadrzędny/Podrzędny.';
    $Self->{Translation}->{'Enables the feature that secondary tickets follow the primary ticket to a new primary in the advanced PrimarySecondary mode.'} =
        'Włącza funkcjonalność dodatkową, dzięki której zgłoszenia podrzędne podążają za zgłoszeniem nadrzędnym do nowego zgłoszenia nadrzędnego.';
    $Self->{Translation}->{'Enables the feature to change the PrimarySecondary state of a ticket in the advanced PrimarySecondary mode.'} =
        'Włącza funkcjonalność dodatkową dzięki której można zmienić stan zgłoszenia Nadrzędny/Podrzędny.';
    $Self->{Translation}->{'Enables the feature to forward articles from type \'forward\' of a primary ticket to the customers of the secondary tickets. By default (disabled) it will not forward articles from type \'forward\' to the secondary tickets.'} =
        '';
    $Self->{Translation}->{'Enables the feature to keep parent-child link after change of the PrimarySecondary state in the advanced PrimarySecondary mode.'} =
        '';
    $Self->{Translation}->{'Enables the feature to keep parent-child link after unset of the PrimarySecondary state in the advanced PrimarySecondary mode.'} =
        '';
    $Self->{Translation}->{'Enables the feature to unset the PrimarySecondary state of a ticket in the advanced PrimarySecondary mode.'} =
        '';
    $Self->{Translation}->{'If a note is added by an agent, sets the state of the ticket in the ticket PrimarySecondary screen of a zoomed ticket in the agent interface.'} =
        '';
    $Self->{Translation}->{'Parameters for the dashboard backend of the primary tickets overview of the agent interface. "Limit" is the number of entries shown by default. "Group" is used to restrict the access to the plugin (e. g. Group: admin;group1;group2;). "Default" determines if the plugin is enabled by default or if the user needs to enable it manually. "CacheTTLLocal" is the cache time in minutes for the plugin.'} =
        '';
    $Self->{Translation}->{'Parameters for the dashboard backend of the secondary tickets overview of the agent interface. "Limit" is the number of entries shown by default. "Group" is used to restrict the access to the plugin (e. g. Group: admin;group1;group2;). "Default" determines if the plugin is enabled by default or if the user needs to enable it manually. "CacheTTLLocal" is the cache time in minutes for the plugin.'} =
        '';
    $Self->{Translation}->{'Primary / Secondary'} = '';
    $Self->{Translation}->{'Primary Tickets'} = '';
    $Self->{Translation}->{'PrimarySecondary'} = '';
    $Self->{Translation}->{'PrimarySecondary module for Ticket Bulk feature.'} = '';
    $Self->{Translation}->{'Registration of the ticket event module.'} = '';
    $Self->{Translation}->{'Required permissions to use the ticket PrimarySecondary screen of a zoomed ticket in the agent interface.'} =
        '';
    $Self->{Translation}->{'Secondary Tickets'} = '';
    $Self->{Translation}->{'Sets if Primary / Secondary field must be selected by the agent.'} =
        '';
    $Self->{Translation}->{'Sets the default body text for notes added in the ticket PrimarySecondary screen of a zoomed ticket in the agent interface.'} =
        '';
    $Self->{Translation}->{'Sets the default subject for notes added in the ticket PrimarySecondary screen of a zoomed ticket in the agent interface.'} =
        '';
    $Self->{Translation}->{'Sets the responsible agent of the ticket in the ticket PrimarySecondary screen of a zoomed ticket in the agent interface.'} =
        '';
    $Self->{Translation}->{'Sets the service in the ticket PrimarySecondary screen of a zoomed ticket in the agent interface (Ticket::Service needs to be activated).'} =
        '';
    $Self->{Translation}->{'Sets the ticket owner in the ticket PrimarySecondary screen of a zoomed ticket in the agent interface.'} =
        '';
    $Self->{Translation}->{'Sets the ticket type in the ticket PrimarySecondary screen of a zoomed ticket in the agent interface (Ticket::Type needs to be activated).'} =
        '';
    $Self->{Translation}->{'Shows a link in the menu to change the PrimarySecondary status of a ticket in the ticket zoom view of the agent interface.'} =
        '';
    $Self->{Translation}->{'Shows a list of all the involved agents on this ticket, in the ticket PrimarySecondary screen of a zoomed ticket in the agent interface.'} =
        '';
    $Self->{Translation}->{'Shows a list of all the possible agents (all agents with note permissions on the queue/ticket) to determine who should be informed about this note, in the ticket PrimarySecondary screen of a zoomed ticket in the agent interface.'} =
        '';
    $Self->{Translation}->{'Shows the ticket priority options in the ticket PrimarySecondary screen of a zoomed ticket in the agent interface.'} =
        '';
    $Self->{Translation}->{'Shows the title field in the ticket PrimarySecondary screen of a zoomed ticket in the agent interface.'} =
        '';
    $Self->{Translation}->{'Specifies the different article communication channels where the real name from Primary ticket will be replaced with the one in the Secondary ticket.'} =
        '';
    $Self->{Translation}->{'This module activates Primary/Secondary field in new email and phone ticket screens.'} =
        '';
    $Self->{Translation}->{'This setting is deprecated and will be removed in further versions of ZnunyPrimarySecondary.'} =
        '';
    $Self->{Translation}->{'Ticket PrimarySecondary.'} = '';


    push @{ $Self->{JavaScriptStrings} // [] }, (
    );

}

1;
