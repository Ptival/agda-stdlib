------------------------------------------------------------------------
-- The Maybe type
------------------------------------------------------------------------

module Data.Maybe where

------------------------------------------------------------------------
-- The type

data Maybe (A : Set) : Set where
  just    : (x : A) -> Maybe A
  nothing : Maybe A

------------------------------------------------------------------------
-- Some operations

open import Data.Bool
open import Data.Unit

boolToMaybe : Bool -> Maybe ⊤
boolToMaybe true  = just _
boolToMaybe false = nothing

maybeToBool : forall {A} -> Maybe A -> Bool
maybeToBool (just _) = true
maybeToBool nothing  = false

-- A non-dependent eliminator.

maybe : {a b : Set} -> (a -> b) -> b -> Maybe a -> b
maybe j n (just x) = j x
maybe j n nothing  = n

maybe₀₁ : {a : Set} {b : Set1} -> (a -> b) -> b -> Maybe a -> b
maybe₀₁ j n (just x) = j x
maybe₀₁ j n nothing  = n

------------------------------------------------------------------------
-- Maybe monad

open import Data.Function
open import Category.Functor
open import Category.Monad

MaybeFunctor : RawFunctor Maybe
MaybeFunctor = record
  { _<$>_ = \f -> maybe (just ∘ f) nothing
  }

MaybeMonad : RawMonad Maybe
MaybeMonad = record
  { return = just
  ; _>>=_  = _>>=_
  }
  where
  _>>=_ : forall {a b} -> Maybe a -> (a -> Maybe b) -> Maybe b
  nothing >>= f = nothing
  just x  >>= f = f x

MaybeMonadZero : RawMonadZero Maybe
MaybeMonadZero = record
  { monad = MaybeMonad
  ; ∅     = nothing
  }

MaybeMonadPlus : RawMonadPlus Maybe
MaybeMonadPlus = record
  { monadZero = MaybeMonadZero
  ; _∣_       = _∣_
  }
  where
  _∣_ : forall {a} -> Maybe a -> Maybe a -> Maybe a
  nothing ∣ y = y
  just x  ∣ y = just x

------------------------------------------------------------------------
-- Equality

open import Relation.Nullary
open import Relation.Binary
open import Relation.Binary.PropositionalEquality

drop-just : forall {A} {x y : A} -> just x ≡ just y -> x ≡ y
drop-just ≡-refl = ≡-refl

just≢nothing : forall {A} {x : A} -> just x ≢ nothing
just≢nothing ()

decSetoid : forall {A} -> Decidable (_≡_ {A}) -> DecSetoid
decSetoid {A} _A-≟_ = ≡-decSetoid _≟_
  where
  _≟_ : Decidable (_≡_ {Maybe A})
  just x  ≟ just y  with x A-≟ y
  just x  ≟ just .x | yes ≡-refl = yes ≡-refl
  just x  ≟ just y  | no  x≢y    = no (x≢y ∘ drop-just)
  just x  ≟ nothing = no just≢nothing
  nothing ≟ just y  = no (just≢nothing ∘ ≡-sym)
  nothing ≟ nothing = yes ≡-refl
