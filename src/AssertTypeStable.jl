module AssertTypeStable

using InteractiveUtils
using Cthulhu

export @assert_typestable, @istypestable

macro assert_typestable(ex0...)
    InteractiveUtils.gen_call_with_extracted_types_and_kwargs(__module__, :assert_typestable, ex0)
end

function assert_typestable(@nospecialize(F), @nospecialize(TT); seen_methods=Set{Tuple{Function,Type}}(), kwargs...)
    # ============ Recurse into its children FIRST (so we get a bottom-up walk?) ================

    # Prevent infinite-loops for recursive functions.
    if (F,TT) in seen_methods
        return
    end
    push!(seen_methods, (F,TT))

    # Get code for this method.
    # ----- Copied from Cthulhu ---------
    methods = code_typed(F, TT; kwargs...)
    if isempty(methods)
        methodstr = _print_method_to_string(F, TT)
        @warn "$methodstr has no methods -- call will fail!"
        return
    end
    CI, rt = first(methods)
    callsites = Cthulhu.find_callsites(CI, TT; kwargs...)
    # ----- /Copied from Cthulhu ---------

    # Recurse
    for callsite in callsites
        assert_typestable(callsite.f, callsite.tt; seen_methods=seen_methods, kwargs...)
    end

    # ============ Then check this method. ==========================
    code_assertstable(F, TT)

end

_print_method_to_string(f, tt) = "$f($( join(["::$_t" for _t in tt.parameters], ", ") ))"

@enum TypeStability stable=1 expected_union=2 unstable=3

# Copied from code_warntype:
function code_assertstable(@nospecialize(f), @nospecialize(t); debuginfo::Symbol=:default)
    for (src, rettype) in code_typed(f, t)
        stability = assert_type_type_checker(rettype)
        if stability == unstable
            methodstr = _print_method_to_string(f, t)
            @warn "Type instability encountered in $methodstr. Printing `@code_warntype $methodstr`:"
            code_warntype(f,t)
            throw(AssertionError("type-instability: $rettype"))
        elseif stability == expected_union
            methodstr = _print_method_to_string(f, t)
            @warn "Encountered expected small-union type in $methodstr: $rettype"
        end
    end
    nothing
end

function assert_type_type_checker(@nospecialize(ty))
    if ty isa Type && (!Base.isdispatchelem(ty) || ty == Core.Box)
        if ty isa Union && Base.is_expected_union(ty)
            return expected_union
        else
            return unstable
        end
    else
        return stable
    end
end

macro istypestable(ex0...)
    esc(quote
        try
            AssertTypeStable.@assert_typestable $(ex0...)
        catch e
            if e isa AssertionError
                return false
            end
        end
        return true
    end)
end

end
