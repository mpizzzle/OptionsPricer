#!/usr/local/bin/bqn

# TODO:
# wrap in a library, make it easy to use
# extended Greeks?

# inverse of average absolute deviation
# https://en.wikipedia.org/wiki/Average_absolute_deviation#Relation_to_standard_deviation
iaad ← 1 ÷ √2 × π

# (Standard Normal) Cumulative Distribution Function
# https://en.wikipedia.org/wiki/Normal_distribution#Error_function
CDF ← 0.5 × 1 + ·•math.Erf ÷⟜(√2)

# Probability Density Function
# https://en.wikipedia.org/wiki/Normal_distribution#Standard_normal_distribution
PDF ← iaad × ·⋆ 2 ÷˜ ¯1 × ⋆⟜2

# Applies the Black-Scholes model for finding the theoretical fair value of an option.
#
# inputs:
# S - price of underlying asset (at time t)
# K - strike price
# τ - time until contract maturity (T - t) in years
# σ - volatility of underlying asset
# r - interest rate
# c - 0 for call, 1 for put
#
# outputs an array of:
# Delta  (Δ) - sensitivity of the option's value
#   with respect to the asset price.
# Gamma  (Γ) - sensitivity of Δ
#   with respect to the asset price.
# Vega   (𝜈) - sensitivity of the option's value
#   with respect to volatility.
# Theta  (Θ) - rate at which the option loses value
#   with respect to time.
# Rho    (ρ) - sensitivity of the option's value
#   with respect to interest rate.
# Lambda (λ) - percentage change in option's value
#   with respect to the asset price.
# Value  (V) - theoretical fair value of the option.
#
# https://en.wikipedia.org/wiki/Black–Scholes_model#The_Options_Greeks

Greeks ← {
  s‿k‿t‿v‿r‿c ← 𝕩

  # these are easier to interpret concretely after applying CDF (Φ)
  # CDF d1 - Δ (hedge ratio)
  # CDF d2 - probability that underlying price > than strike price
  #   i.e. P(in the money baby)
  #
  # https://gregorygundersen.com/blog/2024/09/28/black-scholes/
  d ← (⋆⁼ s ÷ k) + (r + 2 ÷˜ v ⋆ 2) × t
  d1‿d2 ← d (÷(⊣⋈-)⊢) v × √t

  sign ← ¯1 × 1 -˜ 2 × c # convert c to 1 for call, ¯1 for put
  pdfd1 ← PDF d1
  cdfd2 ← CDF sign × d2

  # wikipedia lists this as 'dual delta (δV / δK)', × k, I don't have an interpretation.
  # refactor this into something more meaningful?
  ddk ← (sign × cdfd2 × ⋆ ¯1 × r × t) × k

  # https://en.wikipedia.org/wiki/Greeks_(finance)#Formulae_for_European_option_Greeks
  delta ← c -˜ CDF d1
  gamma ← pdfd1 ÷ s × v × √t
  vega ← pdfd1 × s × √t
  theta ← (ddk × r) -˜ ¯1 × t ÷˜ 0.5 × v × vega
  rho ← ddk × t
  value ← ddk -˜ delta × s
  lambda ← delta × s ÷ value

  delta‿gamma‿vega‿theta‿rho‿lambda‿value
}

# Solving for IV does not have a closed form, so we iterate on the Black-Scholes model by
# tweaking σ until the output theoretical value matches the known option market value.
# https://en.wikipedia.org/wiki/Implied_volatility#Solving_the_inverse_pricing_model_function
#
# We do this via Newton-Raphson, i.e.
# σₙ₊₁ = σₙ - (V_model - V_market) / 𝜈
# https://en.wikipedia.org/wiki/Newton's_method
#
# inputs:
# S - price of underlying asset (at time t)
# K - strike price
# τ - time until contract maturity (T - t) in years
# σ - initial guess at volatility of underlying asset (is this needed?)
# r - interest rate
# c - 0 for call, 1 for put
# m - actual market value of the option
# v - theoretical fair value of the option
#
# outputs:
# IV - implied volatility that satisfies the Black-Scholes equation
#   for the option's actual market value.
ImpliedVolatility ← 3 ⊑ {
  s‿k‿t‿v‿r‿c‿m‿q ← 𝕩

  sign ← ¯1 × 1 -˜ 2 × c
  d ← (⋆⁼ s ÷ k) + (r + 2 ÷˜ v ⋆ 2) × t
  d1‿d2 ← d (÷(⊣⋈-)⊢) v × √t

  cdfd2 ← CDF sign × d2
  delta ← c -˜ CDF d1
  val ← (s × delta) - k × sign × cdfd2 × ⋆ ¯1 × r × t
  vega ← (PDF d2) × s × √t

  s‿k‿t‿(v - vega ÷˜ val - m)‿r‿c‿m‿val
} •_while_ (1e¯10 < ·|∘-´ ¯2⊸↑)

# S - price of underlying asset (at time t)
# K - strike price
# τ - time until contract maturity (T - t) in years
# σ - volatility of underlying asset
# r - interest rate
# c - 0 for call, 1 for put
# m - actual market value of the option
inputs ← 100‿100‿1‿0.20‿0.05‿0‿10

•Show ⍉ ⟨
  "underlying price (Sₜ)",
  "strike price (K)",
  "time until maturity (T - t)",
  "Estimated Volatility (σ)",
  "Interest Rate (r)",
  "Call or Put (0 ∨ 1)",
  "Market Value (m)"
⟩ ≍ inputs

outputs ← Greeks ¯1 ↓ inputs
iv ← ImpliedVolatility inputs ∾ ¯1 ⊑ outputs

•Show ⍉ ⟨
  "Delta (Δ)",
  "Gamma (Γ)",
  "Vega (𝜈)",
  "Theta (Θ)",
  "Rho (ρ)",
  "Lambda (λ)",
  "Theoretical Value (V)",
  "Implied Volatility (IV)"
⟩ ≍ outputs ∾ iv
