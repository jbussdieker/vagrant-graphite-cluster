hiera_include('classes')
create_resources('host', hiera('hosts'))
