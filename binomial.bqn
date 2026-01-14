#!/usr/local/bin/bqn

# S - price of underlying asset (at time t)
# K - strike price
# τ - time until contract maturity (T - t) in years
# σ - volatility of underlying asset
# r - interest rate
# c - 0 for call, 1 for put
# n - number of rows in binomial tree
inputs ← 100‿100‿1‿0.20‿0.05‿0‿5000

 •Show ⍉ ⟨
   "underlying price (Sₜ)",
   "strike price (K)",
   "time until maturity (T - t)",
   "Estimated Volatility (σ)",
   "Interest Rate (r)",
   "Call or Put (0 ∨ 1)",
   "Depth of Binomial Tree (n)",
 ⟩ ≍ inputs

# Applies the Binomial Options Pricing model to discretely
# approximate the fair value of an option.
#
# inputs:
# S - price of underlying asset (at time t)
# K - strike price
# τ - time until contract maturity (T - t) in years
# σ - volatility of underlying asset
# r - interest rate
# c - 0 for call, 1 for put
# n - number of rows in binomial tree
#
# outputs:
# Value  (V) - theoretical fair value of the option.
#
# https://en.wikipedia.org/wiki/Binomial_options_pricing_model#Method

Binomial ← {
  s‿k‿t‿v‿r‿c‿n ← 𝕩

  dt ← t ÷ n # Δt represents time slice for one layer of binomial tree
  d‿u ← ÷⊸⋈ ⋆ v × √dt
  p ← u ÷˜○(-⟜d) ⋆r×dt # probability that option value increases at Δt
  b ← s × u ⋆ (⊢-2×·↕1⊸+) n # bottom row of binomial tree
  max ← 0 ⌈ k c ◶ (-˜)‿- b # option values at bottom row
  exp ← ⋆ ¯1 × r × ÷n

  (exp × p (⊢⋈1⊸-)⊸(+´×)⎉0‿1 2⊸↕)⍟n max
}

outputs ← Binomial inputs

•Show ⍉ ⟨
  "Theoretical Value (V)",
⟩ ≍ outputs
