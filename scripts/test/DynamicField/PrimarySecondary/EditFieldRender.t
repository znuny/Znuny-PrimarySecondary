# --
# Copyright (C) 2001-2021 OTRS AG, https://otrs.com/
# Copyright (C) 2021 Znuny GmbH, https://znuny.org/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

use strict;
use warnings;
use utf8;

use vars (qw($Self));

use Kernel::System::VariableCheck qw(:all);

# get needed objects
my $DynamicFieldObject = $Kernel::OM->Get('Kernel::System::DynamicField');
my $ParamObject        = $Kernel::OM->Get('Kernel::System::Web::Request');

$Kernel::OM->ObjectParamAdd(
    'Kernel::Output::HTML::Layout' => {
        UserID => 1,
    },
);
my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
my $ConfigObject = $Kernel::OM->Get('Kernel::Config');

# get helper object
$Kernel::OM->ObjectParamAdd(
    'Kernel::System::UnitTest::Helper' => {
        RestoreDatabase => 1,
    },
);
my $HelperObject = $Kernel::OM->Get('Kernel::System::UnitTest::Helper');

# ------------------------------------------------------------ #
# make preparations
# ------------------------------------------------------------ #

# get Primary/Secondary dynamic field data
my $PrimarySecondaryDynamicField     = $ConfigObject->Get('PrimarySecondary::DynamicField');
my $PrimarySecondaryDynamicFieldData = $DynamicFieldObject->DynamicFieldGet(
    Name => $PrimarySecondaryDynamicField,
);

my $TicketObject = $Kernel::OM->Get('Kernel::System::Ticket');

# find all current open primary secondary tickets
my @TicketIDs = $TicketObject->TicketSearch(
    Result => 'ARRAY',

    # primary secondary dynamic field
    'DynamicField_' . $PrimarySecondaryDynamicField => {
        Equals => 'Primary',
    },

    StateType  => 'Open',
    UserID     => 1,
    Permission => 'ro',
);

# set tickets to removed so they are not fond later in the test cases
#    the tickets will be restored automatically at the end of the test
#    due to the RestoreDatabase option in helper object
for my $TicketID (@TicketIDs) {
    my $Success = $TicketObject->TicketStateSet(
        State    => 'removed',
        TicketID => $TicketID,
        UserID   => 1,
    );
    $Self->True(
        $Success,
        "Temporary set Primary Ticket: $TicketID to removed",
    );
}

# define tests
my @Tests = (
    {
        Name   => 'PrimarySecondary - Possible Values Filter',
        Config => {
            DynamicFieldConfig   => $PrimarySecondaryDynamicFieldData,
            PossibleValuesFilter => {
                Primary => 'New Primary Ticket',
            },
            LayoutObject => $LayoutObject,
            ParamObject  => $ParamObject,
        },
        ExpectedResults => {
            Field =>
                '<select class="DynamicFieldText Modernize" id="DynamicField_PrimarySecondary" name="DynamicField_PrimarySecondary" size="1">
  <option value="Primary">New Primary Ticket</option>
</select>
',
            Label => '<label id="LabelDynamicField_PrimarySecondary" for="DynamicField_PrimarySecondary">
Primary Ticket:
</label>
'
        },
    },
    {
        Name   => 'UnsetPrimarySecondary - Possible Values Filter',
        Config => {
            DynamicFieldConfig   => $PrimarySecondaryDynamicFieldData,
            PossibleValuesFilter => {
                Primary        => 'New Primary Ticket',
                UnsetPrimary   => 'Unset Primary Tickets',
                UnsetSecondary => 'Unset Secondary Tickets',
            },
            LayoutObject => $LayoutObject,
            ParamObject  => $ParamObject,
        },
        ExpectedResults => {
            Field =>
                '<select class="DynamicFieldText Modernize" id="DynamicField_PrimarySecondary" name="DynamicField_PrimarySecondary" size="1">
  <option value="Primary">New Primary Ticket</option>
  <option value="UnsetPrimary">Unset Primary Tickets</option>
  <option value="UnsetSecondary">Unset Secondary Tickets</option>
</select>
',
            Label => '<label id="LabelDynamicField_PrimarySecondary" for="DynamicField_PrimarySecondary">
Primary Ticket:
</label>
'
        },
    },
    {
        Name   => 'PrimarySecondary: No value ',
        Config => {
            DynamicFieldConfig => $PrimarySecondaryDynamicFieldData,
            LayoutObject       => $LayoutObject,
            ParamObject        => $ParamObject,
            Class              => 'MyClass',
            UseDefaultValue    => 0,
        },
        ExpectedResults => {
            Field => <<"EOF" . '</select>',
<select class="DynamicFieldText Modernize MyClass" id="DynamicField_PrimarySecondary" name="DynamicField_PrimarySecondary" size="1">
  <option value="">-</option>
  <option value="Primary">New Primary Ticket</option>
EOF
            Label => '<label id="LabelDynamicField_PrimarySecondary" for="DynamicField_PrimarySecondary">
Primary Ticket:
</label>
'
        },
    },
    {
        Name   => 'PrimarySecondary: No value / Default',
        Config => {
            DynamicFieldConfig => $PrimarySecondaryDynamicFieldData,
            LayoutObject       => $LayoutObject,
            ParamObject        => $ParamObject,
            Class              => 'MyClass',
        },
        ExpectedResults => {
            Field => <<"EOF" . '</select>',
<select class="DynamicFieldText Modernize MyClass" id="DynamicField_PrimarySecondary" name="DynamicField_PrimarySecondary" size="1">
  <option value="" selected="selected">-</option>
  <option value="Primary">New Primary Ticket</option>
EOF
            Label => '<label id="LabelDynamicField_PrimarySecondary" for="DynamicField_PrimarySecondary">
Primary Ticket:
</label>
'
        },
    },
    {
        Name   => 'PrimarySecondary: Value direct',
        Config => {
            DynamicFieldConfig => $PrimarySecondaryDynamicFieldData,
            LayoutObject       => $LayoutObject,
            ParamObject        => $ParamObject,
            Value              => 'Primary',
            Class              => 'MyClass',
            UseDefaultValue    => 0,
        },
        ExpectedResults => {
            Field => <<"EOF" . '</select>',
<select class="DynamicFieldText Modernize MyClass" id="DynamicField_PrimarySecondary" name="DynamicField_PrimarySecondary" size="1">
  <option value="">-</option>
  <option value="Primary" selected="selected">New Primary Ticket</option>
EOF
            Label => '<label id="LabelDynamicField_PrimarySecondary" for="DynamicField_PrimarySecondary">
Primary Ticket:
</label>
'
        },
    },
    {
        Name   => 'PrimarySecondary: Mandatory',
        Config => {
            DynamicFieldConfig => $PrimarySecondaryDynamicFieldData,
            LayoutObject       => $LayoutObject,
            ParamObject        => $ParamObject,
            Value              => 'Primary',
            Class              => 'MyClass',
            UseDefaultValue    => 0,
            Mandatory          => 1,
        },
        ExpectedResults => {
            Field =>
                '<select class="DynamicFieldText Modernize MyClass Validate_Required" id="DynamicField_PrimarySecondary" name="DynamicField_PrimarySecondary" size="1">
  <option value="">-</option>
  <option value="Primary" selected="selected">New Primary Ticket</option>
</select>
<div id="DynamicField_PrimarySecondaryError" class="TooltipErrorMessage">
    <p>
        This field is required.
    </p>
</div>
',
            Label =>
                '<label id="LabelDynamicField_PrimarySecondary" for="DynamicField_PrimarySecondary" class="Mandatory">
    <span class="Marker">*</span>
Primary Ticket:
</label>
'
        },
    },
    {
        Name   => 'PrimarySecondary: Server Error',
        Config => {
            DynamicFieldConfig => $PrimarySecondaryDynamicFieldData,
            LayoutObject       => $LayoutObject,
            ParamObject        => $ParamObject,
            Value              => 'Primary',
            Class              => 'MyClass',
            UseDefaultValue    => 0,
            ServerError        => 1,
            ErrorMessage       => 'This is an error.'
        },
        ExpectedResults => {
            Field =>
                '<select class="DynamicFieldText Modernize MyClass ServerError" id="DynamicField_PrimarySecondary" name="DynamicField_PrimarySecondary" size="1">
  <option value="">-</option>
  <option value="Primary" selected="selected">New Primary Ticket</option>
</select>
<div id="DynamicField_PrimarySecondaryServerError" class="TooltipErrorMessage">
    <p>
        This is an error.
    </p>
</div>
',
            Label => '<label id="LabelDynamicField_PrimarySecondary" for="DynamicField_PrimarySecondary">
Primary Ticket:
</label>
'
        },
    },
);

# ------------------------------------------------------------ #
# execute tests
# ------------------------------------------------------------ #
my $DynamicFieldBackendObject = $Kernel::OM->Get('Kernel::System::DynamicField::Backend');

for my $Test (@Tests) {

    my $FieldHTML = $DynamicFieldBackendObject->EditFieldRender( %{ $Test->{Config} } );

    # heredocs always have the newline, even if it is not expected
    if ( $FieldHTML->{Field} !~ m{\n$} ) {
        chomp $Test->{ExpectedResults}->{Field};
    }

    $Self->IsDeeply(
        $FieldHTML,
        $Test->{ExpectedResults},
        "$Test->{Name} | EditFieldRender()",
    );
}

# Cleanup is done by RestoreDatabase.

1;
