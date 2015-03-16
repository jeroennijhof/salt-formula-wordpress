{%- from "wordpress/map.jinja" import server with context %}
{%- if server.enabled %}

include:
- git

{%- for app_name, app in server.app.iteritems() %}

  {%- if salt['cmd.run']('wp cli version --allow-root') != 1 %}

    {%- set web_path='/srv/wordpress/sites/'+app_name+'/root/' %}
    
    {%- if salt['cmd.run']('wp core is-installed --path="{{ web_path }}" --allow-root') == 1 %}

      wp_install:
        cmd.run:
          - name: wp core install --url='{{ app.core_install.url }}' --title='{{ app.core_install.title }}' --admin_user='{{ app.core_install.admin_user }}' --admin_password='{{ app.core_install.admin_password }}' --admin_email='{{ app.core_install.admin_email }}' --allow-root
          - cwd: {{ web_path }}
          - user: root
    
    {%- endif %}
  
    {%- if app.do_update.core_update %}
  
      wp_core_update:
        cmd.run:
          - name: wp core update --allow-root
          - cwd: {{ web_path }}
          - user: root
       
    {%- endif %}
  
    {%- if app.do_update.theme_update %}
  
      wp_theme_update:
        cmd.run:
          - name: wp theme update --all --allow-root
          - cwd: {{ web_path }}
          - user: root
       
    {%- endif %}
  
    {%- for plugin_name, plugin in app.plugin.iteritems() %}
  
      {{ plugin_name }}_install:
        cmd.run:
          - name: wp plugin install {{ plugin_name }} --allow-root
          - cwd: {{ web_path }}
          - user: root
          - unless:  wp plugin is-installed {{ plugin_name }} --allow-root
  
      {%- if plugin.version == 'latest' %}
  
        {%- if plugin.source.engine == 'http' %}
    
          {{ plugin_name }}_update:
            cmd.run:
              - name: wp plugin update {{ plugin_name }} --allow-root
              - cwd: {{ web_path }}
              - user: root
    
        {%- elif plugin.source.engine == 'git' %}  
    
        {%- endif %}
  
      {%- else %}
  
        {%- if plugin.source.engine == 'http' %}
    
          {{ plugin_name }}_update:
            cmd.run:
              - name: wp plugin update {{ plugin_name }} --version='{{ plugin.version }}' --allow-root
              - cwd: {{ web_path }}
              - user: root
    
        {%- elif plugin.source.engine == 'git' %}  
    
        {%- endif %}
  
      {%- endif %}
  
    {%- endfor %}
    
  {%- else %}
 
    not_installed:
      cmd.run:
        - name: echo 'TODO - vynuceni default DB.'
 
  {%- endif %}

{%- endfor %}

{%- endif %}


#TODO - test multiple plugin install (for) and enable them. 
#testplugin_install:
#  cmd.run:
#    - name: wp plugin install members --allow-root
#    - cwd: /srv/wordpress/sites/devel/root/
#    - user: root
#    - unless:
#       - wp core is-intalled --allow-root

# Check if WP is installed
