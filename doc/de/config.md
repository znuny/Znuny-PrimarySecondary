# Konfiguration

Znuny-PrimarySecondary wird ausschließlich über die Systemkonfigurationsbereich des Administrationsbereichs konfiguriert. Navigieren Sie zum Menü „Admin“, filtern Sie dann oder scrollen Sie, um den Administrationsblock **Systemkonfiguration** auszuwählen.

Auf der linken Seite können Sie dann die Konfigurationsgruppe Znuny-PrimarySecondary auswählen, um aus den verfügbaren Konfigurationsoptionen des Add-ons zu filtern.

## Standardeinstellungen

Das Paket ist nach der Installation ohne zusätzliche Einstellungen nutzbar. Es ermöglicht Agenten, ein primäres Ticket zu erstellen oder ein Ticket während der Ticketerstellung über das Frontend als sekundäres Ticket eines primären festzulegen.

In diesem *Basismodus* kann das Ticket im Rahmen der folgenden Aktionen zum primären Ticket erklärt werden.

## PrimarySecondary Maske

Durch Aktivieren des *Erweiterten Modus* „PrimarySecondary::AdvancedEnabled“ können Sie ein Ticket über das Ticketmenü &&**PrimarySecondary** als primär festlegen.

Die Konfiguration der **PrimarySecondary**-Maske kann auch um viele weitere Ticketdetails erweitert werden.

* TicketType
* Service
* Owner
* OwnerMandatory
* Responsible
* ResponsibleMandatory
* State
* StateType
* StateDefault
* Note
* NoteMandatory
* Subject
* Body
* InvolvedAgent
* InformAgent
* IsVisibleForCustomerDefault
* Priority
* PriorityDefault
* Title
* PrimarySecondaryMandatory

Zu den Einstellungen, die sich auch über die **PrimarySecondary**-Maske auf die Funktion auswirken können, gehören:

„PrimarySecondary::UnsetPrimarySecondary“ um das Attribut primär/sekundär deaktivieren zu können.

Die obige Einstellung muss aktiviert sein, um bei einer Sammelaktion Tickets einem primären Ticket zuzuordnen.

Aktivieren Sie diese Option „PrimarySecondary::UpdatePrimarySecondary“ um das Attribut primär/sekundär zu ändern.

## Optionale Funktionen

Damit alle sekundären Tickets einem primären zu einem neuen primären Ticket folgen, verwenden Sie die Einstellung „PrimarySecondary::FollowUpdatedPrimary“.

Damit Weiterleitungen sich auf die sekundären Tickets auswirken ist „PrimarySecondary::ForwardSecondary“ zu aktivieren.

Um bei Verknüpfungen das primären/sekundären Attribut zu beachten stehen die Einstellungen „PrimarySecondary::KeepParentChildAfterUnset“ und „PrimarySecondary::KeepParentChildAfterUpdate“ zur Verfügung.

Mit „Ticket::EventModulePost###PrimarySecondary“ steuern Sie, welche Ereignisse auf sekundäre Tickets dupliziert werden sollen.

Um primäre/sekundäre Tickets über die Sammelaktion zu bearbeiten ist die Einstellung „Ticket::Frontend::BulkModule###010-PrimarySecondary“ vorgesehen.

## Verschiedenes

Alle Konfigurationsoptionen finden Sie, indem Sie zu Admin => Systemkonfiguration navigieren und im Navigationsbereich auf der linken Seite der Systemkonfigurationsseite die Gruppe Znuny-PrimarySecondary auswählen oder im Suchfeld nach *primarysecondary* suchen.
