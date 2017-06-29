#!/usr/bin/env dart
import 'dart:io';
import 'package:args/command_runner.dart';
import '../lib/parser.dart';
import '../lib/parser/fis.dart';
import '../lib/parser/profit_stars.dart';

main(List<String> args) {
    var runner = new CommandRunner('ppp-cli', 'Payment PDF Parser CLI')
        ..addCommand(new FileParserCommand())
        ..addCommand(new DirectoryParserCommand());

    runner
        .run(args)
        .catchError((e, stackTrace) {
            String message = e is Exception ? e.message : e.toString();
            print(message);
            //print(stackTrace);
            exit(64);
        });
}

abstract class ParserCommand extends Command {
    Parser provider(type) {
        switch (type) {
            case 'ps':
                return new ProfitStarsParser();
            case 'fis':
                return new FisParser();
            default:
                throw new UsageException('"provider" option must be either "ps" or "fis".', '-p ps');
        }
    }
}

/// File parser command
class FileParserCommand extends ParserCommand {
    final String name = 'file';
    final String description = 'Parse a single PDF file.';

    FileParserCommand() {
        argParser
            ..addOption('file', abbr: 'f', help: 'Path of the PDF file to parse.')
            ..addOption('provider', abbr: 'p', help: 'PDF Provider - "ps" or "fis".')
            ..addFlag('clear', abbr: 'c', help: 'Clear output directory.', negatable: false);
    }

    run() {
        var path = argResults['file'];
        if (path == null) {
            throw new UsageException('"file" option must be set.', 'file -f /path/to/pdf');
        }
        provider(argResults['provider']).parsePdf(path, argResults['clear']);
    }
}

/// Directory parser command
class DirectoryParserCommand extends ParserCommand {
    final String name = 'directory';
    final String description = 'Parse a directory of PDFs.';

    DirectoryParserCommand() {
        argParser
            ..addOption('directory', abbr: 'd', help: 'Directory containing PDF files to parse.')
            ..addOption('provider', abbr: 'p', help: 'PDF Provider - "ps" or "fis".')
            ..addFlag('clear', abbr: 'c', help: 'Clear output directory.', negatable: false);
    }

    run() {
        var path = argResults['directory'];
        if (path == null) {
            throw new UsageException('"directory" option must be set.', 'directory -d /path/to/pdfs');
        }
        provider(argResults['provider']).parseDirectory(path, argResults['clear']);
    }
}