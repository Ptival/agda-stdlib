------------------------------------------------------------------------
-- Integers
------------------------------------------------------------------------

module Prelude.Int where

open import Prelude.Bool
import Prelude.Nat as N
open N using (ℕ)
open import Prelude.Logic
open import Prelude.BinaryRelation
open import Prelude.BinaryRelation.PropositionalEquality
open import Prelude.Algebra
open import Prelude.Algebraoid
import Prelude.RingSolver.Simple as S
import Prelude.Algebra.CommutativeRingProperties as CRProp
import Prelude.Algebra.AlmostCommRingProperties  as AProp
import Prelude.Algebra.Operations as Op

infix  8 +_ -_
infixl 7 _*_ _⊓_
infixl 6 _+_ _-_ _⊔_

------------------------------------------------------------------------
-- The types

postulate
  ℤ   : Set
  _≤_ : ℤ -> ℤ -> Set

{-# BUILTIN INTEGER ℤ #-}

------------------------------------------------------------------------
-- Arithmetic

private
  primitive
    primIntegerPlus   : ℤ -> ℤ -> ℤ
    primIntegerMinus  : ℤ -> ℤ -> ℤ
    primIntegerTimes  : ℤ -> ℤ -> ℤ
    primIntegerLess   : ℤ -> ℤ -> Bool
    primIntegerEquals : ℤ -> ℤ -> Bool
    primNatToInteger  : ℕ -> ℤ
    primIntegerAbs    : ℤ -> ℕ

_+_ : ℤ -> ℤ -> ℤ
_+_ = primIntegerPlus

_-_ : ℤ -> ℤ -> ℤ
_-_ = primIntegerMinus

_*_ : ℤ -> ℤ -> ℤ
_*_ = primIntegerTimes

+_ : ℕ -> ℤ
+_ = primNatToInteger

∣_∣ : ℤ -> ℕ
∣ i ∣ = primIntegerAbs i

0# : ℤ
0# = + 0

1# : ℤ
1# = + 1

-_ : ℤ -> ℤ
- i = 0# - i

suc : ℤ -> ℤ
suc i = i + 1#

pred : ℤ -> ℤ
pred i = i - 1#

_⊔_ : ℤ -> ℤ -> ℤ
i ⊔ j = if primIntegerLess i j then i else j

_⊓_ : ℤ -> ℤ -> ℤ
i ⊓ j = if primIntegerLess i j then j else i

------------------------------------------------------------------------
-- Queries

_≟_ : Decidable {ℤ} _≡_
i ≟ j with primIntegerEquals i j
i ≟ j | true  = yes trustMe
  where postulate trustMe : _
i ≟ j | false = no trustMe
  where postulate trustMe : _

_≤?_ : Decidable {ℤ} _≤_
i ≤? j with primIntegerLess j i
i ≤? j | false = yes trustMe
  where postulate trustMe : _
i ≤? j | true  = no trustMe
  where postulate trustMe : _

------------------------------------------------------------------------
-- Some properties

ℤ-setoid : Setoid
ℤ-setoid = ≡-setoid ℤ

ℤ-decSetoid : DecSetoid
ℤ-decSetoid = record { setoid = ℤ-setoid; _≟_ = _≟_ }

ℤ-poset : Poset
ℤ-poset = record
  { carrier  = ℤ
  ; _≈_      = _≡_
  ; _≤_      = _≤_
  ; ord      = trustMe
  }
  where postulate trustMe : _

ℤ-decTotOrder : DecTotOrder
ℤ-decTotOrder = record
  { poset = ℤ-poset
  ; _≟_   = _≟_
  ; _≤?_  = _≤?_
  ; total = trustMe
  }
  where postulate trustMe : _

ℤ-bareRingoid : BareRingoid
ℤ-bareRingoid = record
  { setoid = ℤ-setoid
  ; _+_    = _+_
  ; _*_    = _*_
  ; -_     = -_
  ; 0#     = 0#
  ; 1#     = 1#
  }

ℤ-commRingoid : CommutativeRingoid
ℤ-commRingoid = record
  { bare     = ℤ-bareRingoid
  ; commRing = trustMe
  }
  where postulate trustMe : _

module ℤ-ringSolver = S (CRProp.almostCommRingoid ℤ-commRingoid)

-- A morphism from the commutative ring over the integers to any other
-- "almost commutative ring".

ℤ-morphism : forall r -> ℤ-bareRingoid -Bare-AlmostComm⟶ r
ℤ-morphism r = record
  { ⟦_⟧    = ⟦_⟧
  ; +-homo = trustMe₁
  ; *-homo = trustMe₂
  ; ¬-homo = trustMe₃
  ; 0-homo = trustMe₄
  ; 1-homo = trustMe₅
  }
  where
  open module R = AlmostCommRingoid r
  module B = BareRingoid bare
  open module R = Setoid B.setoid
  module A = AProp r
  open module O = Op A.semiringoid

  ⟦_⟧ : ℤ -> carrier
  ⟦ i ⟧ with i ≤? (+ 0)
  ⟦ i ⟧ | yes _ = B.-_ (∣ i ∣ × B.1#)
  ⟦ i ⟧ | no _  = ∣ i ∣ × B.1#

  postulate
    trustMe₁ : _ -- forall x y -> ⟦ x + y ⟧ ≈ B._+_ ⟦ x ⟧ ⟦ y ⟧
    trustMe₂ : _ -- forall x y -> ⟦ x * y ⟧ ≈ B._*_ ⟦ x ⟧ ⟦ y ⟧
    trustMe₃ : _ -- forall x   -> ⟦ - x ⟧   ≈ B.-_ ⟦ x ⟧
    trustMe₄ : B.-_ B.0# ≈ B.0#
    trustMe₅ : B._+_ B.1# B.0# ≈ B.1#