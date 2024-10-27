import std.stdio;
import std.range;
import std.file;

void main(string[] args) {
    arg(0, args[0]);
    foreach (argc, argv; args[1 .. $].enumerate) {
        arg(argc, argv);
        writeln(readText(argv));
    }
}

void arg(size_t argc, string argv) {
    writefln("argv[%d] = <%s>", argc, argv);
}
