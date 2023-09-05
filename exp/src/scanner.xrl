Definitions.
D = [0-9]
L = [a-z]

Rules.
{D}+ : {token, {integer, TokenChars}}.
int|float|if|while : {token, {keyword, TokenChars}}.
{L}({L}|{D})+ : {token, {id, TokenChars}}.
[\s\t\n\r]+ :{token, {space, TokenChars}}.
Erlang code.