with Ada.Text_IO;
with Ada.Command_Line;

procedure fibonacci is
    N : Integer := Integer'Value(Ada.Command_Line.Argument(Number => 1));
    function fib(
        N: in Integer)
        return Integer is
        A : Integer := 0;
        B : Integer := 1;
        C : Integer := 1;
    begin
        if (N <= 1)
        then
            return N;
        end if;
        for i in 2 .. N loop
            C := A + B;
            A := B;
            B := C;
        end loop;
        return B;
    end;
begin
    Ada.Text_IO.Put_Line("fib(" & Integer'Image(N) & ") = " & Integer'Image(fib(N)));
end fibonacci;
