A git-excluded source for database and file dumps, in order to provision specific
reusable assets to sites; i.e., for reference databases and files.

The structure expected by the provisioning script will be:

artifacts

 -- sites

 ---- [Name]

 ------dump.sql.gz

 ------files.tar.gz

 Any variation from that, apart from [name], will not work.