A git-excluded source for database and file dumps, in order to provision specific
reusable assets to sites; i.e., for reference databases and files.

The structure expected by the provisioning script will be:

artifacts

 -- sites

 ---- [Name of resource]

 ------dump.sql.gz

 ------files.tar.gz

 Any variation from that, apart from [name of resource], will not work.

 The artifact shell script will prompt you for the docroot name of a site, the name of a resource,
 and ask whether you want to replace the site's db, the files, or both.