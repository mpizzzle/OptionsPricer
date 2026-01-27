# Options Pricer

A Java-based options pricing service that implements Black-Scholes and Binomial pricing models. The service provides REST APIs for calculating theoretical option prices, Greeks (Delta, Gamma, Theta, Vega, Rho, Lambda), and implied volatility.

## Features

- **Black-Scholes Model**: Closed-form analytical pricing for European options
- **Implied Volatility Calculation**: Newton-Raphson method for backing out market implied volatility
- **Greeks Calculation**: Delta, Gamma, Theta, Vega, Rho, and Lambda
- **gRPC Services**: Protocol Buffers-based API definitions
- **Type-Safe**: Generated Java classes from protobuf schemas

## System Dependencies

### Required
- **Java JDK 21+** - [Download](https://adoptium.net/)
- **Maven 3.8+** - [Download](https://maven.apache.org/download.cgi)
- **buf CLI** - [Installation Guide](https://buf.build/docs/installation)

## Project Setup

### 1. Initialize Dependencies/ Generate Classes
```bash
buf dep update
buf generate
```

### 3. Build the Project
```bash
mvn clean install
mvn test
```

## Project Structure

```
.
├── buf.yaml                    # Buf module configuration
├── buf.gen.yaml               # Code generation configuration
├── buf.lock                   # Dependency lock file
├── pom.xml                    # Maven configuration
├── proto/
│   └── options/
│       └── pricer/
│           └── v1/
│               └── options_pricer.proto   # API definitions
├── src/
│   ├── main/java/             # Implementation code
│   └── gen/java/              # Generated protobuf classes (gitignored)
└── README.md
```

## API Overview

### CalculateBlackScholesPrice
Calculate option price and all Greeks using the Black-Scholes model.

**Inputs:**
- Spot price (S)
- Strike price (K)
- Time to maturity (T)
- Volatility (σ)
- Risk-free rate (r)
- Option type (CALL/PUT)

**Outputs:**
- Theoretical value
- Intrinsic value
- Time value
- Greeks: Delta, Gamma, Theta, Vega, Rho, Lambda

### CalculateImpliedVolatility
Calculate implied volatility from market price using Newton-Raphson iteration.

**Inputs:**
- Same as above, plus market price
- Optional: initial guess, max iterations, tolerance

**Outputs:**
- Implied volatility
- Convergence info (iterations, converged flag, final error)

## License

MIT
