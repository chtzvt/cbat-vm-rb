# CBAT VM Instruction Set

## Instruction Set

### I/O and Files
| Instruction | Description | Implemented |
| --- | --- | --- |
| `e STRING` | echo to terminal | Yes |
| `af STRING,PATH` | create/append to file | Yes |
| `wf STRING,PATH` | write/overwrite file | No |
| `df PATH` | delete file | No |
| `t PATH` | type file contents | No |
| `stp IDENT,PROMPT` | Prompt user for IDENT using optional string | Yes |

### Variables 
| Instruction | Description | Implemented |
| --- | --- | --- |
| `st IDENT,VALUE` | set IDENT to VALUE | Yes |
| `sta IDENT,EXPR` | arithmetic set | No |
| `stf PATH IDENT` | set variable content from file | No |

### Control Flow 
| Instruction | Description | Implemented |
| --- | --- | --- |
| `g LABEL` | goto | Yes |
| `l LABEL` | declare a label | Yes | 
| `c PATH` | call | No |
| `trm` | terminate | Yes |
| `iex PATH<,optional LABEL>` | goto if exist | Yes |
| `inx PATH<,optional LABEL>` | goto if not exist | Yes |
| `ieq IDENT,VALUE<,optional LABEL>` | goto if equal | Yes |
| `inq IDENT,VALUE<,optional LABEL>` | goto if not equal | Yes |

Note: If LABEL is unspecified, the instruction immediately following will be executed in the true case or skipped otherwise.

### Utility
| Instruction | Description | Implemented |
| --- | --- | --- |
| `cls` | clear terminal | No |
| `clr INT` | color | No |
| `p INT` | pause, quiet pause if INT = 0 | Yes |

### Mathematics (immediate)
| Instruction | Description | Implemented |
| --- | --- | --- |
| `add DEST IDENT,OP IDENT,OP IDENT` | Add | Yes |
| `sub DEST IDENT,OP IDENT,OP IDENT` | Subtract | Yes |
| `mul DEST IDENT,OP IDENT,OP IDENT` | Multiply | Yes |
| `div DEST IDENT,OP IDENT,OP IDENT` | Divide | Yes |

### Mathematics (immediate)
| Instruction | Description | Implemented |
| --- | --- | --- |
| `adi IDENT,VALUE` | Add | Yes |
| `sbi IDENT,VALUE` | Subtract | Yes |
| `mli IDENT,VALUE` | Multiply | Yes |
| `dvi IDENT,VALUE` | Divide | Yes |

## Built-in Identifiers

| Identifier | Description | Implemented |
| --- | --- | --- |
| `%username%` | current user | Yes |
| `%date%` | current date | Yes |
| `%time%` | current time | Yes |
| `%random%` | random number | Yes |

## CBAT File Format (.cbat)

### Sections

| Section | Description | Optional |
| --- | --- | --- |
| `.global` | Global configuration | No |
| `.files` | Pre-defined global file table | Yes |
| `.header` | Program file header | No |
| `.labels` | Program file label table | Yes |
| `.instrs` | Instructions | No |

### Comments

Comments are denoted by a `;` character. Comments must be placed on their own line and may appear anywhere in the file.

### `.global` Section

| Key | Description | Optional |
| --- | --- | --- |

### `.files` Section

| Key | Description | Optional |
| --- | --- | --- |

### `.header` Section

| Key | Description | Optional |
| --- | --- | --- |

### `.labels` Section

| Key | Description | Optional |
| --- | --- | --- |

### `.instrs` Section

| Key | Description | Optional |
| --- | --- | --- |

## CBAT VM Debugger

### Commands

#### Program Counter

| Command | Description |
| --- | --- |
| `pc` | current PC value |
| `j` | Jump to address |

#### Execution

| Command | Description |
| --- | --- |
| `d` | dump instructions (internal repr) |
| `dc` | dump instructions (cbat repr) |
| `insi` | Insert instruction at address |
| `deli` | delete instruction at address |

#### Variables

| Command | Description |
| --- | --- |
| `vset` | set variable |
| `vdel` | delete variable |
| `vdmp` | dump variables |

#### Labels

| Command | Description |
| --- | --- |
| `lbc` | create label |
| `lbd` | delete label |
| `lbdmp` | dump labels |

#### Files

| Command | Description |
| --- | --- |
| `fcp` | file copy |
| `fdel` | file delete |
| `fr` | read file content |
| `fw` | write file content |
| `fdmp` | dump files |

#### Misc

| Command | Description |
| --- | --- |
| `foutc` | Dump program as cbat |
| `foutb` | Dump program as batch |
| `trm` | Terminate execution |
| `step` | toggle step log |
| `dlog` | toggle step log |


## Example

```batchfile
TEST.BAT

echo "Hello there!"
echo "Welcome to the test program."
set /p NAME=Please enter your name:
echo %NAME% >>"USERS.TXT"
if %NAME% EQU "Charlton" goto WAZZUP
echo "Goodbye, %NAME%"
exit 

:WAZZUP 
echo "Wazzup dad"
```

```
.header
    filename "TEST.BAT"
    entry 0
    ver 0.1
.labels 
    WAZZUP:7
.instrs
    e "Hello there!"
    e "Welcome to the test program."
    stp NAME,"Please enter your name:"
    af NAME,"USERS.TXT"
    ieq NAME,"Charlton",WAZZUP
    e "Goodbye, %NAME%"
    trm
    e "Wazzup dad"
```