pub const binomial = @import("comb/binomial.zig").binomial;

pub const Lex = @import("comb/lex.zig").Lex;

pub const FxtCoLex = @import("comb/colex.zig").FxtCoLex;
pub const KnuthCoLex = @import("comb/colex.zig").KnuthCoLex;
pub const CoLex = KnuthCoLex; // default colex implementation

pub const RevDoor = @import("comb/revdoor.zig").RevDoor;

pub const CoolLex = @import("comb/cool_lex.zig").CoolLex;
pub const CoolLexBitStr = @import("comb/cool_lex.zig").CoolLexBitStr;

pub const SumOfProducts = @import("comb/sum_of_products.zig").SumOfProducts;
pub const sumOfProducts = @import("comb/sum_of_products.zig").sumOfProducts;

pub const lam = @import("comb/lam.zig").lamStatic;
pub const lamProvided = @import("comb/lam.zig").lamProvided;

test {
    _ = @import("comb/binomial.zig");
    _ = @import("comb/lex.zig");
    _ = @import("comb/colex.zig");
    _ = @import("comb/cool_lex.zig");
    _ = @import("comb/revdoor.zig");
    _ = @import("comb/lam.zig");

    _ = @import("comb/sum_of_products.zig");
}
