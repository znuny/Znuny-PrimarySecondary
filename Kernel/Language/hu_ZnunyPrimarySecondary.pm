# --
# Copyright (C) 2021 Znuny GmbH, https://znuny.org/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Language::hu_ZnunyPrimarySecondary;

use strict;
use warnings;
use utf8;

sub Data {
    my $Self = shift;

    # TT Template: Kernel/Output/HTML/Templates/Standard/AgentTicketPrimarySecondary.tt
    $Self->{Translation}->{'Manage Primary/Secondary status for %s%s%s'} = '%s%s%s elsődleges/másodlagos állapotának kezelése';

    # Perl Module: Kernel/Modules/AgentTicketPrimarySecondary.pm
    $Self->{Translation}->{'New Primary Ticket'} = 'Új elsődleges jegy';
    $Self->{Translation}->{'Unset Primary Ticket'} = 'Elsődleges jegy beállításának megszüntetése';
    $Self->{Translation}->{'Unset Secondary Ticket'} = 'Másodlagos jegy beállításának megszüntetése';
    $Self->{Translation}->{'Secondary of %s%s%s: %s'} = '%s%s%s másodlagosa: %s';

    # Perl Module: Kernel/Output/HTML/TicketBulk/PrimarySecondary.pm
    $Self->{Translation}->{'Unset Primary Tickets'} = 'Elsődleges jegyek beállításának megszüntetése';
    $Self->{Translation}->{'Unset Secondary Tickets'} = 'Másodlagos jegyek beállításának megszüntetése';

    # Perl Module: Kernel/System/DynamicField/Driver/PrimarySecondary.pm
    $Self->{Translation}->{'Primary'} = 'Elsődleges';
    $Self->{Translation}->{'Secondary of %s%s%s'} = '%s%s%s másodlagosa';
    $Self->{Translation}->{'Primary Ticket'} = 'Elsődleges jegy';

    # SysConfig
    $Self->{Translation}->{'All primary tickets'} = 'Összes elsődleges jegy';
    $Self->{Translation}->{'All secondary tickets'} = 'Összes másodlagos jegy';
    $Self->{Translation}->{'Allows adding notes in the ticket PrimarySecondary screen of a zoomed ticket in the agent interface.'} =
        'Lehetővé teszi jegyzetek hozzáadását egy nagyított jegynek a jegy elsődleges-másodlagos képernyőjén az ügyintézői felületen.';
    $Self->{Translation}->{'Change the PrimarySecondary state of the ticket.'} = 'A jegy elsődleges-másodlagos állapotának megváltoztatása.';
    $Self->{Translation}->{'Defines dynamic field name for primary ticket feature.'} = 'Meghatározza a dinamikus mező nevét az elsődleges jegy funkcióhoz.';
    $Self->{Translation}->{'Defines if a ticket lock is required in the ticket PrimarySecondary screen of a zoomed ticket in the agent interface (if the ticket isn\'t locked yet, the ticket gets locked and the current agent will be set automatically as its owner).'} =
        'Meghatározza, hogy jegyzárolás szükséges egy nagyított jegynek a jegy elsődleges-másodlagos képernyőjén az ügyintézői felületen (ha a jegy még nincs zárolva, a jegy zárolva lesz, és az aktuális ügyintéző automatikusan beállításra kerül annak tulajdonosaként).';
    $Self->{Translation}->{'Defines if the PrimarySecondary note is visible for the customer by default.'} =
        'Meghatározza, hogy az elsődleges-másodlagos jegyzet alapértelmezetten látható legyen az ügyfélnek.';
    $Self->{Translation}->{'Defines the default next state of a ticket after adding a note, in the ticket PrimarySecondary screen of a zoomed ticket in the agent interface.'} =
        'Meghatározza egy jegy alapértelmezett következő állapotát egy jegyzet hozzáadása után egy nagyított jegynek a jegy elsődleges-másodlagos képernyőjén az ügyintézői felületen.';
    $Self->{Translation}->{'Defines the default ticket priority in the ticket PrimarySecondary screen of a zoomed ticket in the agent interface.'} =
        'Meghatározza az alapértelmezett jegyprioritást egy nagyított jegynek a jegy elsődleges-másodlagos képernyőjén az ügyintézői felületen.';
    $Self->{Translation}->{'Defines the history comment for the ticket PrimarySecondary screen action, which gets used for ticket history in the agent interface.'} =
        'Meghatározza az előzmények megjegyzést a jegy elsődleges-másodlagos képernyő művelethez, amelyet a jegy előzményeinél szoktak használni az ügyintézői felületen.';
    $Self->{Translation}->{'Defines the history type for the ticket PrimarySecondary screen action, which gets used for ticket history in the agent interface.'} =
        'Meghatározza az előzmények típusát a jegy elsődleges-másodlagos képernyő művelethez, amelyet a jegy előzményeinél szoktak használni az ügyintézői felületen.';
    $Self->{Translation}->{'Defines the next state of a ticket after adding a note, in the ticket PrimarySecondary screen of a zoomed ticket in the agent interface.'} =
        'Meghatározza egy jegy következő állapotát egy jegyzet hozzáadása után egy nagyított jegynek a jegy elsődleges-másodlagos képernyőjén az ügyintézői felületen.';
    $Self->{Translation}->{'Enables the advanced PrimarySecondary part of the feature.'} = 'Engedélyezi a funkció speciális elsődleges-másodlagos részét.';
    $Self->{Translation}->{'Enables the feature that secondary tickets follow the primary ticket to a new primary in the advanced PrimarySecondary mode.'} =
        'Engedélyezi azt a funkciót, hogy a másodlagos jegyek kövessék az elsődleges jegyet egy új elsődlegesre a speciális elsődleges-másodlagos módban.';
    $Self->{Translation}->{'Enables the feature to change the PrimarySecondary state of a ticket in the advanced PrimarySecondary mode.'} =
        'Engedélyezi a funkciót egy jegy elsődleges-másodlagos állapotának megváltoztatásához a speciális elsődleges-másodlagos módban.';
    $Self->{Translation}->{'Enables the feature to forward articles from type \'forward\' of a primary ticket to the customers of the secondary tickets. By default (disabled) it will not forward articles from type \'forward\' to the secondary tickets.'} =
        'Engedélyezi a funkciót a bejegyzések továbbításához egy elsődleges jegy „továbbítás” típusából a másodlagos jegyek ügyfeleihez. Alapértelmezetten (letiltva) nem fog bejegyzéseket továbbítani a „továbbítás” típusból a másodlagos jegyekhez.';
    $Self->{Translation}->{'Enables the feature to keep parent-child link after change of the PrimarySecondary state in the advanced PrimarySecondary mode.'} =
        'Engedélyezi az elsődleges-másodlagos állapot megváltoztatása utáni szülő-gyermek kapcsolat megtartását a speciális elsődleges-másodlagos módban.';
    $Self->{Translation}->{'Enables the feature to keep parent-child link after unset of the PrimarySecondary state in the advanced PrimarySecondary mode.'} =
        'Engedélyezi az elsődleges-másodlagos állapot beállításának megszüntetése utáni szülő-gyermek kapcsolat megtartását a speciális elsődleges-másodlagos módban.';
    $Self->{Translation}->{'Enables the feature to unset the PrimarySecondary state of a ticket in the advanced PrimarySecondary mode.'} =
        'Engedélyezi a funkciót egy jegy elsődleges-másodlagos állapota beállításának megszüntetéséhez a speciális elsődleges-másodlagos módban.';
    $Self->{Translation}->{'If a note is added by an agent, sets the state of the ticket in the ticket PrimarySecondary screen of a zoomed ticket in the agent interface.'} =
        'Ha egy ügyintéző hozzáadott egy jegyzetet, akkor beállítja a jegy állapotát egy nagyított jegynek a jegy elsődleges-másodlagos képernyőjén az ügyintézői felületen.';
    $Self->{Translation}->{'Parameters for the dashboard backend of the primary tickets overview of the agent interface. "Limit" is the number of entries shown by default. "Group" is used to restrict the access to the plugin (e. g. Group: admin;group1;group2;). "Default" determines if the plugin is enabled by default or if the user needs to enable it manually. "CacheTTLLocal" is the cache time in minutes for the plugin.'} =
        'Paraméterek az ügyintézői felület elsődleges jegyei áttekintőjének vezérlőpult háttérprogramjához. A „Limit” az alapértelmezetten megjelenített bejegyzések száma. A „Group” használható a hozzáférés korlátozásához a bővítményre (például Group: admin;csoport1;csoport2;). A „Default” jelzi, hogy a bővítmény alapértelmezetten engedélyezve van, vagy hogy a felhasználónak kézzel kell engedélyeznie azt. A „CacheTTLLocal” a bővítmény gyorsítótár ideje percben.';
    $Self->{Translation}->{'Parameters for the dashboard backend of the secondary tickets overview of the agent interface. "Limit" is the number of entries shown by default. "Group" is used to restrict the access to the plugin (e. g. Group: admin;group1;group2;). "Default" determines if the plugin is enabled by default or if the user needs to enable it manually. "CacheTTLLocal" is the cache time in minutes for the plugin.'} =
        'Paraméterek az ügyintézői felület másodlagos jegyei áttekintőjének vezérlőpult háttérprogramjához. A „Limit” az alapértelmezetten megjelenített bejegyzések száma. A „Group” használható a hozzáférés korlátozásához a bővítményre (például Group: admin;csoport1;csoport2;). A „Default” jelzi, hogy a bővítmény alapértelmezetten engedélyezve van, vagy hogy a felhasználónak kézzel kell engedélyeznie azt. A „CacheTTLLocal” a bővítmény gyorsítótár ideje percben.';
    $Self->{Translation}->{'Primary / Secondary'} = 'Elsődleges/másodlagos';
    $Self->{Translation}->{'Primary Tickets'} = 'Elsődleges jegyek';
    $Self->{Translation}->{'PrimarySecondary'} = 'Elsődleges-másodlagos';
    $Self->{Translation}->{'PrimarySecondary module for Ticket Bulk feature.'} = 'Elsődleges-másodlagos modul a jegy tömeges funkciójához.';
    $Self->{Translation}->{'Registration of the ticket event module.'} = 'A jegy esemény modul regisztrációja.';
    $Self->{Translation}->{'Required permissions to use the ticket PrimarySecondary screen of a zoomed ticket in the agent interface.'} =
        'Egy nagyított jegynek a jegy elsődleges-másodlagos képernyőjének használatához szükséges jogosultságok az ügyintézői felületen.';
    $Self->{Translation}->{'Secondary Tickets'} = 'Másodlagos jegyek';
    $Self->{Translation}->{'Sets if Primary / Secondary field must be selected by the agent.'} =
        'Beállítja, hogy az ügyintézőnek ki kell választania az elsődleges/másodlagos mezőt.';
    $Self->{Translation}->{'Sets the default body text for notes added in the ticket PrimarySecondary screen of a zoomed ticket in the agent interface.'} =
        'Beállítja az alapértelmezett törzsszöveget egy nagyított jegynek a jegy elsődleges-másodlagos képernyőjén hozzáadott jegyzeteknél az ügyintézői felületen.';
    $Self->{Translation}->{'Sets the default subject for notes added in the ticket PrimarySecondary screen of a zoomed ticket in the agent interface.'} =
        'Beállítja az alapértelmezett tárgyat egy nagyított jegynek a jegy elsődleges-másodlagos képernyőjén hozzáadott jegyzeteknél az ügyintézői felületen.';
    $Self->{Translation}->{'Sets the responsible agent of the ticket in the ticket PrimarySecondary screen of a zoomed ticket in the agent interface.'} =
        'Beállítja a jegy felelős ügyintézőjét egy nagyított jegynek a jegy elsődleges-másodlagos képernyőjén az ügyintézői felületen.';
    $Self->{Translation}->{'Sets the service in the ticket PrimarySecondary screen of a zoomed ticket in the agent interface (Ticket::Service needs to be activated).'} =
        'Beállítja a szolgáltatást egy nagyított jegynek a jegy elsődleges-másodlagos képernyőjén az ügyintézői felületen (a Ticket::Service modulnak aktiválva kell lennie).';
    $Self->{Translation}->{'Sets the ticket owner in the ticket PrimarySecondary screen of a zoomed ticket in the agent interface.'} =
        'Beállítja a jegy tulajdonosát egy nagyított jegynek a jegy elsődleges-másodlagos képernyőjén az ügyintézői felületen.';
    $Self->{Translation}->{'Sets the ticket type in the ticket PrimarySecondary screen of a zoomed ticket in the agent interface (Ticket::Type needs to be activated).'} =
        'Beállítja a jegy típusát egy nagyított jegynek a jegy elsődleges-másodlagos képernyőjén az ügyintézői felületen (a Ticket::Type modulnak aktiválva kell lennie).';
    $Self->{Translation}->{'Shows a link in the menu to change the PrimarySecondary status of a ticket in the ticket zoom view of the agent interface.'} =
        'Egy hivatkozást jelenít meg a menüben egy jegy elsődleges-másodlagos állapotának megváltoztatásához az ügyintézői felület jegynagyítás nézetében.';
    $Self->{Translation}->{'Shows a list of all the involved agents on this ticket, in the ticket PrimarySecondary screen of a zoomed ticket in the agent interface.'} =
        'Megjeleníti a jegynél részt vett összes ügyintéző listáját egy nagyított jegynek a jegy elsődleges-másodlagos képernyőjén az ügyintézői felületen.';
    $Self->{Translation}->{'Shows a list of all the possible agents (all agents with note permissions on the queue/ticket) to determine who should be informed about this note, in the ticket PrimarySecondary screen of a zoomed ticket in the agent interface.'} =
        'Megjeleníti az összes lehetséges ügyintéző listáját (minden ügyintéző, aki jegyzet jogosultsággal rendelkezik a várólistán vagy jegyen) annak meghatározásához, hogy kit kell értesíteni erről a jegyzetről egy nagyított jegynek a jegy elsődleges-másodlagos képernyőjén az ügyintézői felületen.';
    $Self->{Translation}->{'Shows the ticket priority options in the ticket PrimarySecondary screen of a zoomed ticket in the agent interface.'} =
        'Megjeleníti a jegyprioritás lehetőségeit egy nagyított jegynek a jegy elsődleges-másodlagos képernyőjén az ügyintézői felületen.';
    $Self->{Translation}->{'Shows the title field in the ticket PrimarySecondary screen of a zoomed ticket in the agent interface.'} =
        'Megjeleníti a cím mezőt egy nagyított jegynek a jegy elsődleges-másodlagos képernyőjén az ügyintézői felületen.';
    $Self->{Translation}->{'Specifies the different article communication channels where the real name from Primary ticket will be replaced with the one in the Secondary ticket.'} =
        'Megadja a különböző bejegyzés kommunikációs csatornákat, ahol az elsődleges jegyben lévő valódi név ki lesz cserélve a másodlagos jegyben lévővel.';
    $Self->{Translation}->{'This module activates Primary/Secondary field in new email and phone ticket screens.'} =
        'Ez a modul bekapcsolja az elsődleges/másodlagos mezőt az új e-mail és telefonos jegy képernyőkön.';
    $Self->{Translation}->{'This setting is deprecated and will be removed in further versions of ZnunyPrimarySecondary.'} =
        'Ez a beállítás elavult, és el lesz távolítva a Znuny-PrimarySecondary csomag későbbi verzióiból.';
    $Self->{Translation}->{'Ticket PrimarySecondary.'} = 'Jegy elsődleges-másodlagos.';


    push @{ $Self->{JavaScriptStrings} //= [] }, (
    );

}

1;
