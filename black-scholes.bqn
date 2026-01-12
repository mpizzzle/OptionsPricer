#!/usr/local/bin/bqn

# TODO:
# wrap in a library somehow, make it easy to use
# extended Greeks?

# https://en.wikipedia.org/wiki/Average_absolute_deviation#Relation_to_standard_deviation
# inverse of average absolute deviation
iaad ← 1 ÷ √2 × π

# (Standard Normal) Cumulative Distribution Function
# https://en.wikipedia.org/wiki/Normal_distribution#Error_function
CDF ← 0.5 × 1 + ·•math.Erf ÷⟜(√2)

# Probability Density Function
# https://en.wikipedia.org/wiki/Normal_distribution#Standard_normal_distribution
PDF ← iaad × ·⋆ 2 ÷˜ ¯1 × ⋆⟜2

# https://en.wikipedia.org/wiki/Black–Scholes_model#The_Options_Greeks
# https://en.wikipedia.org/wiki/Greeks_(finance)#Formulae_for_European_option_Greeks
#
# inputs
# S - price of underlying asset (at time t)
# K - strike price
# τ - time until contract maturity (T - t) in years
# σ - volatility of underlying asset
# r - interest rate
# c - 0 for call, 1 for put

# outputs an array of:
# Delta (Δ) - sensitivity of the option's value with respect to the asset price.
#
# Gamma (Γ) - sensitivity of delta (Δ) with respect to the asset price.
#
# Vega (𝜈) - sensitivity of the option's value with respect to volatility.
#
# Theta (Θ) - the rate at which the option loses value with respect to time.
#
# Rho (ρ) - sensitivity of the option's value with respect interest rate.
#
# Lambda (λ) - % change in option's value with respect to the asset price.
#
# Value (V) - theoretical fair value of the option.

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

# https://en.wikipedia.org/wiki/Black–Scholes_model#Black–Scholes_equation
#
# satisfies Black-Scholes for theoretical fair option value
# as a function of Δ, Γ, 𝜈, S, r and σ.
EquationValue ← {
  delta‿gamma‿theta‿s‿r‿v ← 𝕩

  r ÷˜ (r × s × delta) + theta + 0.5 × gamma × v ×○(⋆⟜2) s
}

# returns value (V) ⋈ vega (𝜈), for calculating IV via iterative search.
#
# S - price of underlying asset (at time t)
# K - strike price
# τ - time until contract maturity (T - t) in years
# σ - volatility of underlying asset
# r - interest rate
# c - 0 for call, 1 for put
ModelValue ← {
  s‿k‿t‿v‿r‿c ← 𝕩

  sign ← ¯1 × 1 -˜ 2 × c
  d ← (⋆⁼ s ÷ k) + (r + 2 ÷˜ v ⋆ 2) × t
  cdfd1‿cdfd2 ← CDF¨ d (÷⋈sign×÷-⊢) v × √t

  val ← (s × cdfd1 - c) - k × sign × cdfd2 × ⋆ ¯1 × r × t
  vega ← (PDF d ÷ v × √t) × s × √t
  val‿vega
}

# https://en.wikipedia.org/wiki/Implied_volatility#Solving_the_inverse_pricing_model_function
# Solving for IV does not have a closed form, so we iterate on the Black-Scholes model by
# tweaking σ until the output theoretical value matches the known option value.
#
# https://en.wikipedia.org/wiki/Newton's_method
# We do this via Newton-Raphson, i.e.
# σₙ₊₁ = σₙ - (V_model - V_market) / 𝜈
#
# S - price of underlying asset (at time t)
# K - strike price
# τ - time until contract maturity (T - t) in years
# σ - initial guess at volatility of underlying asset (is this needed?)
# r - interest rate
# c - 0 for call, 1 for put
# m - the actual market value of the option
# v - theoretical option (probably don't need this)
NR ← {
  s‿k‿t‿v‿r‿c‿m‿q ← 𝕩

  val‿vega ← ModelValue s‿k‿t‿v‿r‿c

  s‿k‿t‿(v - vega ÷˜ val - m)‿r‿c‿m‿val
} •_while_ (0 ≠·-´¯2⊸↑)

Volatility ← 3 ⊑ NR

s‿k‿t‿v‿r‿c ← 100‿100‿1‿0.20‿0.05‿0

de‿ga‿ve‿th‿rh‿la‿val ← Greeks s‿k‿t‿v‿r‿c

Volatility s‿k‿t‿v‿r‿c‿10‿val

•Show val ⋈ EquationValue de‿ga‿th‿s‿r‿v
