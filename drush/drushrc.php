<?php

// Get rid of toolbar menu, download admin menu, enable a bunch of modules
// configure views admin ui, set some default variables
$options['shell-aliases']['prep'] = '!drush pm-enable -y admin_menu,admin_menu_toolbar,devel,views_ui,module_filter,token_filter,springboard_token -y && drush pm-disable -y toolbar && drush upwd admin --password=admin && drush vset --exact views_ui_show_listing_filters 1 && drush vset --exact views_ui_show_master_display 1 && drush vset --exact views_ui_show_performance_statistics 1 && drush vset --exact views_ui_show_sql_query 1 && drush vset --exact views_ui_show_listing_filters 1 && drush vset --exact views_skip_cache 1 && drush vset --exact views_ui_show_advanced_column 1 && drush vset --exact views_ui_always_live_preview 1 && drush vset --exact devel_query_sort 0 && drush vset --exact devel_query_display 0 && drush vset --exact devel_memory 1 && drush vset --format=json devel_error_handlers {"4":"4"}';


$options['shell-aliases']['wipe'] = '!drush si sbsetup -y';   

$options['shell-aliases']['make-web'] = 'drush make --working-copy --no-gitinfofile build/springboard-developer.make web';