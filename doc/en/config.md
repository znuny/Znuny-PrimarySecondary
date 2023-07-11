# Configuration

Znuny-PrimarySecondary is configured solely in the system configuration section of the administration area. Navigate to the menu Admin, then filter or scroll to select the administration block **System Configuration**.

On the left, you should then choose the configuration group Znuny-PrimarySecondary, to filter from the available configuration options.

## Default Settings

The package is ready to use by default. It allows users to create a primary ticket or assign the ticket as a secondary ticket during ticket creation via the frontend.

In this *Basic Mode*, the ticket can be declared a primary ticket during the following actions.

## PrimarySecondary Mask

By turning on the *Advanced Mode* ``PrimarySecondary::AdvancedEnabled`` you can set a ticket as primary using the ticket menu &&**PrimarySecondary**.

Configuration of the **PrimarySecondary** mask can also be extended to include many other ticket details.

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

Settings which may also affect the function via the **PrimarySecondary** mask include:

Enable this setting to unset the attribute primary/secondary:
``PrimarySecondary::UnsetPrimarySecondary``

The above setting must be enabled to allow for bulk assignment of tickets to a primary.

Enable this option to modify the attribute primary/secondary.
``PrimarySecondary::UpdatePrimarySecondary``

## Optional functions

To have all secondary follow a primary, to a new primary ticket, use:
``PrimarySecondary::FollowUpdatedPrimary``  

Copy forwards to the secondary tickets using:
``PrimarySecondary::ForwardSecondary``

Affect the linking after modifing primary secondary attribute:
``PrimarySecondary::KeepParentChildAfterUnset``
``PrimarySecondary::KeepParentChildAfterUpdate``

Control which events should duplicate to secondary tickets:
``Ticket::EventModulePost###PrimarySecondary``

Deny or allow a bulk update on tickets.
``Ticket::Frontend::BulkModule###010-PrimarySecondary``

## Miscelaneous

All configuration options are found by navigating to Admin => System Configuration and choosing the Znuny-PrimarySecondary group in the navigation section, on the left side, of the system configuration page or searching for *primarysecondary* in the search field.
