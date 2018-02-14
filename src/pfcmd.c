/*  
  Copyright (C) 2005-2018 Inverse inc.
*/
#include <unistd.h>
#ifndef REAL_PATH
#define REAL_PATH "/usr/local/pf/bin/pfcmd.pl"
#endif

int main(int argc,char** argv,char ** envp)
{
    execve(REAL_PATH, argv, envp);
    /* set the return code to 127 to emulate bash command not found */
    return 127;
}
