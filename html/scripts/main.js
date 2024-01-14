let default_icon = 'fa-regular fa-circle';
let is_target_active = false;
let is_menu_active = false;
let menu_data = [];

/*
let test_menu_data = [
    {
        label: "Test Action 1",
        icon: "fa-solid fa-door-closed",
        colour: 'red',
        action_type: "client_event",
        action: 'boii_target:cl:toggle_vehicle_door',
        params: { door_index: 0 },
        distance: 0.6
    },
    {
        label: "Test Action 2",
        icon: "fa-solid fa-car",
        action_type: "client_event",
        action: 'boii_target:cl:toggle_vehicle_door',
        params: { door_index: 1 },
        distance: 0.6
    },
    {
        label: "Test Action 3",
        icon: "fa-solid fa-key",
        action_type: "client_event",
        colour: 'green',
        action: 'boii_target:cl:toggle_vehicle_door',
        params: { door_index: 2 },
        distance: 0.6
    },
    {
        label: "Test Action 4",
        icon: "fa-solid fa-tools",
        colour: 'purple',
        action_type: "client_event",
        action: 'boii_target:cl:toggle_vehicle_door',
        params: { door_index: 3 },
        distance: 0.6
    },
    {
        label: "Test Action 5",
        icon: "fa-solid fa-gas-pump",
        action_type: "client_event",
        action: 'boii_target:cl:toggle_vehicle_door',
        params: { door_index: 4 },
        distance: 0.6
    },
    {
        label: "Test Action 6",
        icon: "fa-solid fa-tachometer-alt",
        action_type: "client_event",
        action: 'boii_target:cl:toggle_vehicle_door',
        params: { door_index: 5 },
        distance: 0.6
    }
];

$(document).ready(function() {
    menu_data = test_menu_data;
    const DEFAULT_ICON = "fa-regular fa-circle"
    populate_dropdown_with_actions(menu_data);
    show_target(DEFAULT_ICON);
});
*/

window.addEventListener('message', function(event) {
    let data = event.data;
    switch (data.action) {
        case "show_target":
            show_target(data.icon);
            break;
        case "hide_target":
            hide_target();
            break;
        case "activate_target":
            activate_target(data.icon);
            break;
        case "deactivate_target":
            deactivate_target();
            break;
        case "populate_actions":
            menu_data = data.data;
            populate_dropdown_with_actions(menu_data);
            break;
        default:
            break;
    }
});

$(document).ready(function() {
    $(document).on('contextmenu', function(e) {
        e.preventDefault();
        if (is_target_active) {
            $('#dropdown_menu').css('display', 'inline-block');
            populate_dropdown_with_actions(menu_data);
        } 
    });
    $(document).on('click', '.action', function(e) {
        e.stopPropagation();
        let action_id = $(this).data('id');
        handle_action_click(action_id, $(this).find('.label_container').text());
        deactivate_target();
        hide_target();
    });
});

function show_target(icon) {
    $('#target').css('display', 'block');
    default_icon = icon
    $('#target i').attr('class', default_icon);
}

function hide_target() {
    menu_data = [];
    $('#target i').attr('class', default_icon);
    $('#target').css('display', 'none');
    $('.actions').css('display', 'none');
}

function activate_target(icon) {
    $('#target').removeClass('inactive').addClass('active');
    let target_icon = icon;
    $('#target i').attr('class', target_icon);
    is_target_active = true;
}

function deactivate_target() {
    $('#target').removeClass('active').addClass('inactive');
    $('#target i').attr('class', default_icon);
    let menu_left = $('.actions.left');
    let menu_right = $('.actions.right');
    menu_left.empty();
    menu_right.empty();
    is_target_active = false;
}

function adjust_action_positions(menu_left, menu_right) {
    let count_left = menu_left.children().length;
    let count_right = menu_right.children().length;
    menu_left.children().first().css('transform', '');
    menu_left.children().last().css('transform', '');
    menu_right.children().first().css('transform', '');
    menu_right.children().last().css('transform', '');
    if (count_left > 2 || count_right > 2) {
        menu_left.children().first().css('transform', count_left > 2 ? 'translateX(10%)' : '');
        menu_left.children().last().css('transform', count_left > 2 ? 'translateX(10%)' : '');
        menu_right.children().first().css('transform', count_right > 2 ? 'translateX(-10%)' : '');
        menu_right.children().last().css('transform', count_right > 2 ? 'translateX(-10%)' : '');
    }
}

function populate_dropdown_with_actions(actions) {
    $('.actions').css('display', 'flex');
    let menu_left = $('.actions.left');
    let menu_right = $('.actions.right');
    menu_left.empty();
    menu_right.empty();
    actions.forEach((action, index) => {
        let action_html = $(`<div class="action" data-id="${action.label}"></div>`);
        let colour = action.colour || '#b4b4b4';
        let label_html = `<span class="label" style="border: 2px solid ${colour}; color: ${colour};">${action.label}</span>`;
        let icon_html = `<span class="icon" style="border: 2px solid ${colour}; color: ${colour};"><i class="${action.icon}"></i></span>`;

        if (index % 2 === 0) {
            action_html.html(`<div class="label_container">${label_html}${icon_html}</div>`);
            menu_left.append(action_html);
        } else {
            action_html.html(`<div class="label_container">${icon_html}${label_html}</div>`);
            menu_right.append(action_html);
        }
    });
    adjust_action_positions(menu_left, menu_right);
    is_menu_active = true;
}


function handle_action_click(action_id, action_name) {
    const selected_action = menu_data.find(action => action.label === action_id);
    if (selected_action) {
        $.post(`https://${GetParentResourceName()}/trigger_action_event`, JSON.stringify({
            action_type: selected_action.action_type,
            action: selected_action.action,
            params: selected_action.params,
            should_close: true
        }));
    }
    hide_target();
    is_menu_active = false
    $.post('https://boii_target/exit_nui', JSON.stringify({}));
}

$(document).on('keydown', function(e) {
    if (e.key === "Escape" || e.key === "Backspace") {
        is_menu_active = false
        hide_target();
        $.post(`https://${GetParentResourceName()}/exit_nui`, JSON.stringify({}));
    }
});
