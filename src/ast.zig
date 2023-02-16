const std = @import("std");
const token = @import("token.zig");
var gpa = std.heap.GeneralPurposeAllocator(.{}){};

const AST = struct {
  interfaces: []Interface
};

const Interface = struct {
  name: []const u8,
  types: []Record
};

const Record = struct {
  name: []const u8,
  entries: []RecordEntry
};

const RecordEntry = struct {
  field: []const u8,
  value: []const u8
};

pub fn buildAst(tokens: []token.Token) !AST {
  var interfaces = std.ArrayList(Interface).init(gpa.allocator());
  for (tokens) |tok| {
    std.debug.print("THE TOKEN {any}\n", .{tok.kind});
    std.debug.print("THE TOKEN {s}\n", .{tok.val});
  }
  for (tokens) |tok, i| {
    // std.debug.print("THE TOKEN KIND {any}\n", .{tok.kind});
    // std.debug.print("THE TOKEN VAL {s}\n", .{tok.val});
    switch(tok.kind) {
      .interface => {
        const interface = try buildInterface(tokens, i);
        // buildInterface(tokens, i);
        std.debug.print("ADDING AN INTERFACE TO THE AST {any}\n", .{interface});
        try interfaces.append(interface);
      },
      .colon => {},
      .comma => {},
      .lcurl => {},
      .literal => {},
      .rcurl => {},
      .record => {},
      .unsigned32 => {},
      // .colon => {},
      // .colon => {},
      // .colon => {},
      // .colon => {},
    }
  }
  return AST {
    .interfaces = interfaces.items
  };
}

fn buildInterface(tokens: []token.Token, start: u64) !Interface {
  var i = start;
  var types = std.ArrayList(Record).init(gpa.allocator());
  std.debug.print("BUILDING INTERFACE {any}\n", .{tokens[i].kind});
  const name = tokens[i + 1];
  std.debug.print("INTERFACE NAME {s}\n", .{name.val});
  i += 3;
  switch (tokens[i].kind) {
    .interface => {},
    .colon => {},
    .comma => {},
    .lcurl => {},
    .literal => {},
    .rcurl => {},
    .record => {
      std.debug.print("BUILD A RECORD HERE \n", .{});
      const record = try buildRecord(tokens, i);
      try types.append(record);
      std.debug.print("THE RECORD {any}", .{record});
    },
    .unsigned32 => {},
  }
  const interface = Interface {
    .name = name.val,
    .types = types.items
  };
  std.debug.print("NEXT TOK {any}\n", .{tokens[i]});
  // std.debug.print("TEH INTERFACE {any}\n", .{interface});
  return interface;
}

fn buildRecord(tokens: []token.Token, start: u64) !Record {
  var buildingRecord = true;
  var i = start + 1;
  const name = tokens[i].val;
  i += 2;
  std.debug.print("NEXT TOK IN RECORD BUILDING {s}\n", .{tokens[i].val});
  var entries = std.ArrayList(RecordEntry).init(gpa.allocator());
  while (buildingRecord) {
    const entry = buildRecordEntry(tokens, i);
    i += 2;
    try entries.append(entry);
    if (tokens[i + 2].kind != token.TokenType.literal) {
      buildingRecord = false;
    }
    i += 2;
  }
  return Record {
    .name = name,
    .entries = entries.items
  };
}

fn buildRecordEntry(tokens: []token.Token, start: u64) RecordEntry {
  var i = start;
  const field = tokens[i].val;
  const value = tokens[i + 2].val;
  std.debug.print("NEXT TOK IN ENTRY BUILDING {s}\n", .{tokens[i].val});
  return RecordEntry {
    .field = field,
    .value = value
  };
}