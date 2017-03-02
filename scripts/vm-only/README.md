These scripts should only execute via vagrant ssh, or directly in the vm, so that copy, move and delete
operations can't accidentally cross the shared folder boundary on the host.