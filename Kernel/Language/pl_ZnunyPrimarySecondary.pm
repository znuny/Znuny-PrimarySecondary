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
    $Self->{Translation}->{'Manage Primary/Secondary status for %s%s%s'} = 'Zarządzaj statusem Nadrzędny/Podrzędny dla %s%s%s';

    # Perl Module: Kernel/Modules/AgentTicketPrimarySecondary.pm
    $Self->{Translation}->{'New Primary Ticket'} = 'Nowe zgłoszenie nadrzędne';
    $Self->{Translation}->{'Unset Primary Ticket'} = 'Unieważnij nadrzędność';
    $Self->{Translation}->{'Unset Secondary Ticket'} = 'Unieważnij podrzędność';
    $Self->{Translation}->{'Secondary of %s%s%s: %s'} = 'Podrzędny do %s%s%s: %s';

    # Perl Module: Kernel/Output/HTML/TicketBulk/PrimarySecondary.pm
    $Self->{Translation}->{'Unset Primary Tickets'} = 'Unieważnij nadrzędność zgłoszeń';
    $Self->{Translation}->{'Unset Secondary Tickets'} = 'Unieważnij podrzędność zgłoszeń';

    # Perl Module: Kernel/System/DynamicField/Driver/PrimarySecondary.pm
    $Self->{Translation}->{'Primary'} = 'Nadrzędny';
    $Self->{Translation}->{'Secondary of %s%s%s'} = 'Podrzędny do %s%s%s';
    $Self->{Translation}->{'Primary Ticket'} = 'Zgłoszenie nadrzędne';

    # SysConfig
    $Self->{Translation}->{'All primary tickets'} = 'Wszystkie zgłoszenia nadrzędne';
    $Self->{Translation}->{'All secondary tickets'} = 'Wszystkie zgłoszenia podrzędne';
    $Self->{Translation}->{'Allows adding notes in the ticket PrimarySecondary screen of a zoomed ticket in the agent interface.'} =
        'Pozwala na dodawanie notatek w oknie NadrzędnyPodrzędny w szczegółach zgłoszenia interfejsu agenta.';
    $Self->{Translation}->{'Change the PrimarySecondary state of the ticket.'} = 'Zmień stan NadrzędnyPodrzędny zgłoszenia.';
    $Self->{Translation}->{'Defines dynamic field name for primary ticket feature.'} = 'Określa nazwę pola dynamicznego do funkcjonalności nadrzędności.';
    $Self->{Translation}->{'Defines if a ticket lock is required in the ticket PrimarySecondary screen of a zoomed ticket in the agent interface (if the ticket isn\'t locked yet, the ticket gets locked and the current agent will be set automatically as its owner).'} =
        'Określa czy jest potrzebna blokada na zgłoszeniu w oknie NadzrzędnyPodrzędny w szczegółach zgłoszenia interfejsu agenta. Zgłoszenie zostanie zablokowane, a bieżący agent stanie sie automatycznie właścicielem.';
    $Self->{Translation}->{'Defines if the PrimarySecondary note is visible for the customer by default.'} =
        'Określa czy notatka z okna NadrzędnyPodrzędny jest domyślnie widoczna dla klienta.';
    $Self->{Translation}->{'Defines the default next state of a ticket after adding a note, in the ticket PrimarySecondary screen of a zoomed ticket in the agent interface.'} =
        'Określa domyślny następny stan zgłoszenia po dodaniu notatki w oknie NadrzędnyPodrzędny w szczegółach zgłoszenia interfejsu agenta.';
    $Self->{Translation}->{'Defines the default ticket priority in the ticket PrimarySecondary screen of a zoomed ticket in the agent interface.'} =
        'Określa domyślny priorytet zgłoszenia w oknie NadrzędnyPodrzędny w szczegółach zgłoszenia interfejsu agenta.';
    $Self->{Translation}->{'Defines the history comment for the ticket PrimarySecondary screen action, which gets used for ticket history in the agent interface.'} =
        'Określa komentarz historii po akcji w oknie NadrzędnyPodrzędny, jaki zostanie zapisany w historii zgłoszenia z interfejsu agenta.';
    $Self->{Translation}->{'Defines the history type for the ticket PrimarySecondary screen action, which gets used for ticket history in the agent interface.'} =
        'Określa typ historii po akcji w oknie NadrzędnyPodrzędny, jaki zostanie zapisany w historii zgłoszenia z interfejsu agenta.';
    $Self->{Translation}->{'Defines the next state of a ticket after adding a note, in the ticket PrimarySecondary screen of a zoomed ticket in the agent interface.'} =
        'Określa następny stan zgłoszenia po dodaniu notatki w oknie NadrzędnyPodrzędny w szczegółach zgłoszenia interfejsu agenta.';
    $Self->{Translation}->{'Enables the advanced PrimarySecondary part of the feature.'} = 'Włącza ustawienia zaawansowane funkcjonalności NadrzędnyPodrzędny.';
    $Self->{Translation}->{'Enables the feature that secondary tickets follow the primary ticket to a new primary in the advanced PrimarySecondary mode.'} =
        'Włącza funkcjonalność zaawansowaną podążania zgłoszeń podrzędnych za zgłoszeniem nadrzędnym do nowego zgłoszenia nadrzędnego.';
    $Self->{Translation}->{'Enables the feature to change the PrimarySecondary state of a ticket in the advanced PrimarySecondary mode.'} =
        'Włącza funkcjonalność zaawansowaną zmiany stanu nadrzędności zgłoszenia.';
    $Self->{Translation}->{'Enables the feature to forward articles from type \'forward\' of a primary ticket to the customers of the secondary tickets. By default (disabled) it will not forward articles from type \'forward\' to the secondary tickets.'} =
        'Włącza funkcjonalność przekazywania artykułów typu \'przekaż\' ze zgłoszenia nadrzędnego do klientów zgłoszeń podrzędnych. Domyślnie (wyłączone) artykuły typu \'przekaż\' nie są przekazywane do zgłoszeń podrzędnych.';
    $Self->{Translation}->{'Enables the feature to keep parent-child link after change of the PrimarySecondary state in the advanced PrimarySecondary mode.'} =
        'Włącza funkcjonalność zaawansowaną utrzymywania łącza rodzic-potomek po zmianie stanu nadrzędności.';
    $Self->{Translation}->{'Enables the feature to keep parent-child link after unset of the PrimarySecondary state in the advanced PrimarySecondary mode.'} =
        'Włącza funkcjonalność zaawansowaną utrzymywania łącza rodzic-potomek po usunięciu stanu nadrzędności lub podrzędności.';
    $Self->{Translation}->{'Enables the feature to unset the PrimarySecondary state of a ticket in the advanced PrimarySecondary mode.'} =
        'Włącza funkcjonalność zaawansowaną usunięcia stanu nadrzędności lub podrzędności zgłoszenia.';
    $Self->{Translation}->{'If a note is added by an agent, sets the state of the ticket in the ticket PrimarySecondary screen of a zoomed ticket in the agent interface.'} =
        'Umożliwia zmianę stanu zgłoszenia na ekranie NadrzędnyPodrzędny w interfejsie agenta.';
    $Self->{Translation}->{'Parameters for the dashboard backend of the primary tickets overview of the agent interface. "Limit" is the number of entries shown by default. "Group" is used to restrict the access to the plugin (e. g. Group: admin;group1;group2;). "Default" determines if the plugin is enabled by default or if the user needs to enable it manually. "CacheTTLLocal" is the cache time in minutes for the plugin.'} =
        'Ustawienie parametrów przeglądu na pulpicie dla zgłoszeń nadrzędnych w interfejsie agenta. „Limit” określa liczbę wpisów wyświetlanych domyślnie. „Grupa” służy do ograniczania dostępu do wtyczki (np. Grupa: admin;group1;group2;). „Domyślnie” określa, czy wtyczka jest domyślnie aktywowana, czy też użytkownik musi ją aktywować samodzielnie. „CacheTTLLocal” to czas buforowania wtyczki, określony w minutach.';
    $Self->{Translation}->{'Parameters for the dashboard backend of the secondary tickets overview of the agent interface. "Limit" is the number of entries shown by default. "Group" is used to restrict the access to the plugin (e. g. Group: admin;group1;group2;). "Default" determines if the plugin is enabled by default or if the user needs to enable it manually. "CacheTTLLocal" is the cache time in minutes for the plugin.'} =
        'Ustawienie parametrów przeglądu na pulpicie dla zgłoszeń podrzędnych w interfejsie agenta. „Limit” określa liczbę wpisów wyświetlanych domyślnie. „Grupa” służy do ograniczania dostępu do wtyczki (np. Grupa: admin;group1;group2;). „Dpmyślnie” określa, czy wtyczka jest domyślnie aktywowana, czy też użytkownik musi ją aktywować samodzielnie. „CacheTTLLocal” to czas buforowania wtyczki określony w minutach.';
    $Self->{Translation}->{'Primary / Secondary'} = 'Nadrzędny / Podrzędny';
    $Self->{Translation}->{'Primary Secondary'} = 'Nadrzędne Podrzędne';
    $Self->{Translation}->{'Primary Tickets'} = 'Zgłoszenia nadrzędne';
    $Self->{Translation}->{'PrimarySecondary'} = 'NadrzędnyPodrzędny';
    $Self->{Translation}->{'PrimarySecondary module for Ticket Bulk feature.'} = 'Moduł NadrzędnyPodrzędny dla operacji zbiorczych na zgłoszeniu.';
    $Self->{Translation}->{'Registration of the ticket event module.'} = 'Rejestracja modułu zdarzeń dla zgłoszenia.';
    $Self->{Translation}->{'Required permissions to use the ticket PrimarySecondary screen of a zoomed ticket in the agent interface.'} =
        'Uprawnienia wymagane do używania okna NadrzędnyPodrzędny w szczegółach zgłoszenia interfejsu agenta.';
    $Self->{Translation}->{'Secondary Tickets'} = 'Zgłoszenia podrzędne';
    $Self->{Translation}->{'Sets if Primary / Secondary field must be selected by the agent.'} =
        'Ustawia pole Nadrzędny / Podrzędny jako wymagane od agenta.';
    $Self->{Translation}->{'Sets the default body text for notes added in the ticket PrimarySecondary screen of a zoomed ticket in the agent interface.'} =
        'Ustawia domyślną treść notatki dodawanej w oknie NadrzędnyPodrzędny w szczegółach zgłoszenia interfejsu agenta.';
    $Self->{Translation}->{'Sets the default subject for notes added in the ticket PrimarySecondary screen of a zoomed ticket in the agent interface.'} =
        'Ustawia domyślny temat notatki dodawanej w oknie NadrzędnyPodrzędny w szczegółach zgłoszenia interfejsu agenta.';
    $Self->{Translation}->{'Sets the responsible agent of the ticket in the ticket PrimarySecondary screen of a zoomed ticket in the agent interface.'} =
        'Ustawia agenta odpowiedzialnego za zgłoszenie w oknie NadrzędnyPodrzędny w szczegółach zgłoszenia interfejsu agenta.';
    $Self->{Translation}->{'Sets the service in the ticket PrimarySecondary screen of a zoomed ticket in the agent interface (Ticket::Service needs to be activated).'} =
        'Ustawia usługę w oknie NadrzędnyPodrzędny w szczegółach zgłoszenia interfejsu agenta (Ticket::Service musi być aktywowane).';
    $Self->{Translation}->{'Sets the ticket owner in the ticket PrimarySecondary screen of a zoomed ticket in the agent interface.'} =
        'Ustawia właściciela zgłoszenia w oknie NadrzędnyPodrzędny w szczegółach zgłoszenia interfejsu agenta.';
    $Self->{Translation}->{'Sets the ticket type in the ticket PrimarySecondary screen of a zoomed ticket in the agent interface (Ticket::Type needs to be activated).'} =
        'Ustawia typ zgłoszenia w oknie NadrzędnyPodrzędny w szczegółach zgłoszenia interfejsu agenta (Ticket::Type musi być włączone).';
    $Self->{Translation}->{'Shows a link in the menu to change the PrimarySecondary status of a ticket in the ticket zoom view of the agent interface.'} =
        'Pokazuje link w menu szczegółów zgłoszenia do zmiany stanu nadrzędności zgłoszenia w interfejsie agenta.';
    $Self->{Translation}->{'Shows a list of all the involved agents on this ticket, in the ticket PrimarySecondary screen of a zoomed ticket in the agent interface.'} =
        'Pokazuje listę wszystkich agentów zaangażowanych w zgłoszenie w oknie NadrzędnyPodrzędny w szczegółach zgłoszenia interfejsu agenta.';
    $Self->{Translation}->{'Shows a list of all the possible agents (all agents with note permissions on the queue/ticket) to determine who should be informed about this note, in the ticket PrimarySecondary screen of a zoomed ticket in the agent interface.'} =
        'Pokazuje listę wszystkich możliwych agentów (wszystkich z uprawnieniami do notatek w kolejce lub zgłoszeniu) w celu określenia kto powinien być poinformowany o tej notatce, w oknie NadrzędnyPodrzędny w szczegółach zgłoszenia interfejsu agenta.';
    $Self->{Translation}->{'Shows the ticket priority options in the ticket PrimarySecondary screen of a zoomed ticket in the agent interface.'} =
        'Pokazuje opcję priorytetu zgłoszenia w oknie NadrzędnyPodrzędny w szczegółach zgłoszenia interfejsu agenta.';
    $Self->{Translation}->{'Shows the title field in the ticket PrimarySecondary screen of a zoomed ticket in the agent interface.'} =
        'Pokazuje pole tytułu w oknie NadrzędnyPodrzędny w szczegółach zgłoszenia interfejsu agenta.';
    $Self->{Translation}->{'Specifies the different article communication channels where the real name from Primary ticket will be replaced with the one in the Secondary ticket.'} =
        'Określa różne kanały komunikacji artykułu, gdzie prawdziwa nazwa ze zgłoszenia nadrzędnego zostanie zastąpiona w zgłoszeniach podrzędnych.';
    $Self->{Translation}->{'This module activates Primary/Secondary field in new email and phone ticket screens.'} =
        'Ten moduł aktywuje pole Nadrzędnt/Podrzędny na ekranach nowego zgłoszenia email i telefonicznego.';
    $Self->{Translation}->{'This setting is deprecated and will be removed in further versions of ZnunyPrimarySecondary.'} =
        'To ustawienie jest już nieaktualne i zostanie usunięte w następnych wersjach ZnunyPrimarySecondary.';
    $Self->{Translation}->{'Ticket PrimarySecondary.'} = 'Zgłoszenie NadrzędnePodrzędne.';


    push @{ $Self->{JavaScriptStrings} //= [] }, (
    );

}

1;
