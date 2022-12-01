pub const binomial = @import("comb/binomial.zig").binomial;

pub const Lex = @import("comb/lex.zig").Lex;
pub const CoLex = @import("comb/colex.zig").CoLex;
pub const CoolLex = @import("comb/cool_lex.zig").CoolLex;
pub const CoolLexBitStr = @import("comb/cool_lex.zig").CoolLexBitStr;
pub const RevDoor = @import("comb/revdoor.zig").RevDoor;
pub const SumOfProducts = @import("comb/sum_of_products.zig").SumOfProducts;

pub const Lam = @import("comb/lam.zig").Lam;
pub const lam = @import("comb/lam.zig").lam;
pub const lam2 = @import("comb/lam.zig").lam2;
pub const lamStatic = @import("comb/lam.zig").lamStatic;

test {
    _ = @import("comb/binomial.zig");
    _ = @import("comb/lex.zig");
    _ = @import("comb/colex.zig");
    _ = @import("comb/cool_lex.zig");
    _ = @import("comb/revdoor.zig");

    _ = @import("comb/sum_of_products.zig");
}
