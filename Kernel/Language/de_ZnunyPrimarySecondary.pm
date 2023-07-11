# --
# Copyright (C) 2021 Znuny GmbH, https://znuny.org/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Language::de_ZnunyPrimarySecondary;

use strict;
use warnings;
use utf8;

sub Data {
    my $Self = shift;

    # TT Template: Kernel/Output/HTML/Templates/Standard/AgentTicketPrimarySecondary.tt
    $Self->{Translation}->{'Manage Primary/Secondary status for %s%s%s'} = 'Primary/Secondary-Status verwalten für %s%s%s';

    # Perl Module: Kernel/Modules/AgentTicketPrimarySecondary.pm
    $Self->{Translation}->{'New Primary Ticket'} = 'Neues Primary-Ticket';
    $Self->{Translation}->{'Unset Primary Ticket'} = 'Aufheben des Primary-Ticket';
    $Self->{Translation}->{'Unset Secondary Ticket'} = 'Aufheben des Secondary-Ticket';
    $Self->{Translation}->{'Secondary of %s%s%s: %s'} = 'Secondary von %s%s%s: %s';

    # Perl Module: Kernel/Output/HTML/TicketBulk/PrimarySecondary.pm
    $Self->{Translation}->{'Unset Primary Tickets'} = 'Aufheben der Primary-Tickets';
    $Self->{Translation}->{'Unset Secondary Tickets'} = 'Aufheben der Secondary-Tickets';

    # Perl Module: Kernel/System/DynamicField/Driver/PrimarySecondary.pm
    $Self->{Translation}->{'Primary'} = 'Primary';
    $Self->{Translation}->{'Secondary of %s%s%s'} = 'Secondary von %s%s%s';
    $Self->{Translation}->{'Primary Ticket'} = 'Primary Ticket';

    # SysConfig
    $Self->{Translation}->{'All primary tickets'} = 'Alle Primary Tickets';
    $Self->{Translation}->{'All secondary tickets'} = 'Alle Secondary-Tickets';
    $Self->{Translation}->{'Allows adding notes in the ticket PrimarySecondary screen of a zoomed ticket in the agent interface.'} =
        'Erlaubt das hinzufügen von Notizen in der PrimarySecondary-Ansicht eines aufgerufenen Tickets in der Agenten-Oberfläche.';
    $Self->{Translation}->{'Change the PrimarySecondary state of the ticket.'} = 'Den PrimarySecondary-Status des Tickets ändern.';
    $Self->{Translation}->{'Defines dynamic field name for primary ticket feature.'} = 'Dynamisches Feld für das Primary-Ticket-Feature definieren.';
    $Self->{Translation}->{'Defines if a ticket lock is required in the ticket PrimarySecondary screen of a zoomed ticket in the agent interface (if the ticket isn\'t locked yet, the ticket gets locked and the current agent will be set automatically as its owner).'} =
        'Bestimmt, ob dieser Screen im Agenten-Interface das Sperren des Tickets voraussetzt. Das Ticket wird (falls nötig) gesperrt und der aktuelle Agent wird als Besitzer gesetzt.';
    $Self->{Translation}->{'Defines if the PrimarySecondary note is visible for the customer by default.'} =
        'Definiert, ob die PrimarySecondary-Notiz standardmäßig für Kunden sichtbar ist.';
    $Self->{Translation}->{'Defines the default next state of a ticket after adding a note, in the ticket PrimarySecondary screen of a zoomed ticket in the agent interface.'} =
        'Bestimmt den Folgestatus für Tickets, für die im PrimarySecondary-Bildschirm des Agenten-Interface eine Notiz hinzugefügt wurde.';
    $Self->{Translation}->{'Defines the default ticket priority in the ticket PrimarySecondary screen of a zoomed ticket in the agent interface.'} =
        'Bestimmt die standardmäßige Ticket-Priorität für Tickets im PrimarySecondary-Bildschirm des Agenten-Interface.';
    $Self->{Translation}->{'Defines the history comment for the ticket PrimarySecondary screen action, which gets used for ticket history in the agent interface.'} =
        'Bestimmt den Historien-Kommentar von Ticket-Aktionen im PrimarySecondary-Bildschirm, welcher für die Ticket-Historie im Agenten-Interface verwendet wird.';
    $Self->{Translation}->{'Defines the history type for the ticket PrimarySecondary screen action, which gets used for ticket history in the agent interface.'} =
        'Bestimmt den Historien-Typ von Ticket-Aktionen im PrimarySecondary-Bildschirm, welcher für die Ticket-Historie im Agenten-Interface verwendet wird.';
    $Self->{Translation}->{'Defines the next state of a ticket after adding a note, in the ticket PrimarySecondary screen of a zoomed ticket in the agent interface.'} =
        'Bestimmt den Folgestatus für Tickets, für die im PrimarySecondary-Bildschirm des Agenten-Interface eine Notiz hinzugefügt wurde.';
    $Self->{Translation}->{'Enables the advanced PrimarySecondary part of the feature.'} = 'Das erweiterte Verhalten des PrimarySecondary-Features aktivieren.';
    $Self->{Translation}->{'Enables the feature that secondary tickets follow the primary ticket to a new primary in the advanced PrimarySecondary mode.'} =
        'Aktiviert die Funktionalität, dass Secondary-Tickets dem Primary-Ticket im erweiterten PrimarySecondary-Verhalten zum neuen Primary folgen.';
    $Self->{Translation}->{'Enables the feature to change the PrimarySecondary state of a ticket in the advanced PrimarySecondary mode.'} =
        'Aktiviert die Funktionalität zum Ändern des PrimarySecondary-Status eines Tickets im erweiterten PrimarySecondary-Modus.';
    $Self->{Translation}->{'Enables the feature to forward articles from type \'forward\' of a primary ticket to the customers of the secondary tickets. By default (disabled) it will not forward articles from type \'forward\' to the secondary tickets.'} =
        'Aktiviert die Funktion zum Weiterleiten von Artikeln des Typs \'Weiterleiten\' zu den Kunden des Secondary-Tickets. Standardmäßig (deaktiviert) werden keine Artikel des Typs \'Weiterleiten\' an die Secondary-Tickets weitergeleitet.';
    $Self->{Translation}->{'Enables the feature to keep parent-child link after change of the PrimarySecondary state in the advanced PrimarySecondary mode.'} =
        'Aktiviert im die Funktion, im erweiterten PrimarySecondary-Verhalten eine Eltern-Kind-Beziehung nach dem Ändern des PrimarySecondary-Status zu behalten.';
    $Self->{Translation}->{'Enables the feature to keep parent-child link after unset of the PrimarySecondary state in the advanced PrimarySecondary mode.'} =
        'Aktiviert im die Funktion, im erweiterten PrimarySecondary-Verhalten eine Eltern-Kind-Beziehung nach dem Auflösen des PrimarySecondary-Status zu behalten.';
    $Self->{Translation}->{'Enables the feature to unset the PrimarySecondary state of a ticket in the advanced PrimarySecondary mode.'} =
        'Aktiviert die Funktion zum Aufheben des PrimarySecondary-Status eines Tickets im erweiterten PrimarySecondary-Verhalten.';
    $Self->{Translation}->{'If a note is added by an agent, sets the state of the ticket in the ticket PrimarySecondary screen of a zoomed ticket in the agent interface.'} =
        'Ermöglicht das Ändern des TIcket-Status beim Hinzufügen einer Notiz innerhalb des PrimarySecondary-Bildschirms.';
    $Self->{Translation}->{'Parameters for the dashboard backend of the primary tickets overview of the agent interface. "Limit" is the number of entries shown by default. "Group" is used to restrict the access to the plugin (e. g. Group: admin;group1;group2;). "Default" determines if the plugin is enabled by default or if the user needs to enable it manually. "CacheTTLLocal" is the cache time in minutes for the plugin.'} =
        'Einstellung der Übersichtsseitenparameter für Primary Tickets in der Agentenoberfläche. "Limit" gibt die Anzahl der standardmäßig dargestellten Einträge an. "Group" wird verwendet, um den Zugriff auf das Plugin zu begrenzen (bspw. Group: admin;group1;group2;). "Default" bestimmt, ob das Plugin standardmäßig aktiviert ist oder ob der Benutzer es selbst aktivieren muss. "CacheTTLLocal" ist die Caching-Zeit des Plugins, angegeben in Minuten.';
    $Self->{Translation}->{'Parameters for the dashboard backend of the secondary tickets overview of the agent interface. "Limit" is the number of entries shown by default. "Group" is used to restrict the access to the plugin (e. g. Group: admin;group1;group2;). "Default" determines if the plugin is enabled by default or if the user needs to enable it manually. "CacheTTLLocal" is the cache time in minutes for the plugin.'} =
        'Einstellung der Übersichtsseitenparameter für Secondary Tickets in der Agentenoberfläche. "Limit" gibt die Anzahl der standardmäßig dargestellten Einträge an. "Group" wird verwendet, um den Zugriff auf das Plugin zu begrenzen (bspw. Group: admin;group1;group2;). "Default" bestimmt, ob das Plugin standardmäßig aktiviert ist oder ob der Benutzer es selbst aktivieren muss. "CacheTTLLocal" ist die Caching-Zeit des Plugins, angegeben in Minuten.';
    $Self->{Translation}->{'Primary / Secondary'} = 'Primary / Secondary';
    $Self->{Translation}->{'Primary Tickets'} = 'Primary-Tickets';
    $Self->{Translation}->{'PrimarySecondary'} = 'PrimarySecondary';
    $Self->{Translation}->{'PrimarySecondary module for Ticket Bulk feature.'} = 'PrimarySecondary-Modul für Ticket-Sammelaktionen.';
    $Self->{Translation}->{'Registration of the ticket event module.'} = 'Registrierung des Ticket-Event-Moduls.';
    $Self->{Translation}->{'Required permissions to use the ticket PrimarySecondary screen of a zoomed ticket in the agent interface.'} =
        'Benötigte Berechtigungen für die Anzeige des PrimarySecondary-Dialogs im Ticket-Zoom-Dialog des Agenteninterface.';
    $Self->{Translation}->{'Secondary Tickets'} = 'Secondary-Tickets';
    $Self->{Translation}->{'Sets if Primary / Secondary field must be selected by the agent.'} =
        'Legt fest, ob Primary / Secondary Feld durch einen Agenten ausgewählt sein muss.';
    $Self->{Translation}->{'Sets the default body text for notes added in the ticket PrimarySecondary screen of a zoomed ticket in the agent interface.'} =
        'Bestimmt den standardmäßigen Text einer Notiz für Tickets im PrimarySecondary-Bildschirm des Agenten-Interface.';
    $Self->{Translation}->{'Sets the default subject for notes added in the ticket PrimarySecondary screen of a zoomed ticket in the agent interface.'} =
        'Bestimmt den standardmäßigen Betreff einer Notiz für Tickets im PrimarySecondary-Bildschirm des Agenten-Interface.';
    $Self->{Translation}->{'Sets the responsible agent of the ticket in the ticket PrimarySecondary screen of a zoomed ticket in the agent interface.'} =
        'Bestimmt den verantwortlichen Agenten eines Tickets im PrimarySecondary Bildschirm des Agenten-Interface für ein aufgerufenes Ticket.';
    $Self->{Translation}->{'Sets the service in the ticket PrimarySecondary screen of a zoomed ticket in the agent interface (Ticket::Service needs to be activated).'} =
        'Bestimmt den Service eines Tickets im PrimarySecondary-Bildschirm des Agenten-Interface für ein aufgerufenes Ticket (Ticket::Service muss aktiviert sein).';
    $Self->{Translation}->{'Sets the ticket owner in the ticket PrimarySecondary screen of a zoomed ticket in the agent interface.'} =
        'Bestimmt den Besitzer eines Tickets im PrimarySecondary-Bildschirm des Agenten-Interface für ein aufgerufenes Ticket.';
    $Self->{Translation}->{'Sets the ticket type in the ticket PrimarySecondary screen of a zoomed ticket in the agent interface (Ticket::Type needs to be activated).'} =
        'Bestimmt den Ticket-Typ eines Tickets im PrimarySecondary-Bildschirm des Agenten-Interface für ein aufgerufenes Ticket (Ticket::Type muss aktiviert sein).';
    $Self->{Translation}->{'Shows a link in the menu to change the PrimarySecondary status of a ticket in the ticket zoom view of the agent interface.'} =
        'Zeigt einen Link zum Ändern des PrimarySecondary-Status eines Tickets im Menü der Ticket-Zoom-Ansicht des Agenten an.';
    $Self->{Translation}->{'Shows a list of all the involved agents on this ticket, in the ticket PrimarySecondary screen of a zoomed ticket in the agent interface.'} =
        'Zeigt eine Liste aller involvierten Agenten für das gewählte Ticket im PrimarySecondary-Bildschirm des Agenten-Interface an.';
    $Self->{Translation}->{'Shows a list of all the possible agents (all agents with note permissions on the queue/ticket) to determine who should be informed about this note, in the ticket PrimarySecondary screen of a zoomed ticket in the agent interface.'} =
        'Zeigt eine Liste aller möglichen Agenten (alle Agenten mit Notiz Berechtigung auf der Queue/dem Ticket) für das gewählte Ticket im PrimarySecondary-Bildschirm des Agenten-Interface an.';
    $Self->{Translation}->{'Shows the ticket priority options in the ticket PrimarySecondary screen of a zoomed ticket in the agent interface.'} =
        'Zeigt die Priorität eines Tickets im PrimarySecondary-Bildschirm des Agenten-Interface für ein aufgerufenes Ticket an.';
    $Self->{Translation}->{'Shows the title field in the ticket PrimarySecondary screen of a zoomed ticket in the agent interface.'} =
        'Zeigt das Titel-Feld in der PrimarySecondary-Oberfläche eines aufgerufenen Tickets im Agenten-Interface an. ';
    $Self->{Translation}->{'Specifies the different article communication channels where the real name from Primary ticket will be replaced with the one in the Secondary ticket.'} =
        'Gibt die verschiedenen Artikel-Kommunikationskanäle an, bei denen der echte Name vom Primary-Ticket durch den im Secondary-Ticket ersetzt wird.';
    $Self->{Translation}->{'This module activates Primary/Secondary field in new email and phone ticket screens.'} =
        'Dieses Modul aktiviert das Primary/Secondary-Feld in der Anzeige für ein neues Email- oder Telefon-Ticket.';
    $Self->{Translation}->{'This setting is deprecated and will be removed in further versions of ZnunyPrimarySecondary.'} =
        'Diese Einstellung ist veraltet und wird in weiteren Versionen von ZnunyPrimarySecondary entfernt.';
    $Self->{Translation}->{'Ticket PrimarySecondary.'} = 'Ticket PrimarySecondary.';


    push @{ $Self->{JavaScriptStrings} // [] }, (
    );

}

1;
