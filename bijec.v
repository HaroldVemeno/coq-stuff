
Require Import Arith Lia.

Record iso (A B : Set) : Set :=
  bijection {
    A_to_B : A -> B;
    B_to_A : B -> A;
    A_B_A  : forall a : A, B_to_A (A_to_B a) = a;
    B_A_B  : forall b : B, A_to_B (B_to_A b) = b
  }.

(* Task 0 : Example of iso in finite sets *)
(* Find a bijection between bool and bit. (provided for you as an example) *)
Inductive bit : Set := b0 | b1.

Definition bool2bit (b : bool) : bit :=
  match b with true => b1 | false => b0
  end.

Definition bit2bool (b : bit) : bool :=
  match b with b1 => true | b0 => false
  end.

Definition bool_iso_bit : iso bool bit.
Proof.
  apply (bijection _ _ bool2bit bit2bool).
  intros.
  case a.
  simpl.
  reflexivity.
  simpl.
  reflexivity.
  intros.
  case b.
  simpl.
  reflexivity.
  simpl.
  reflexivity.
Qed.


(******************************************)
(* Task 1 : General properties of iso *)
(* Task 1-1. Prove that any set has the same cardinality as itself. *)
Theorem iso_refl : forall A : Set, iso A A.
Proof.
  intros.
  apply (bijection _ _ id id);
    unfold id; reflexivity.
  Qed.

(* Task 1-2. Prove that iso is symmetric. *)
Theorem iso_sym : forall A B : Set, iso A B -> iso B A.
Proof.
  intros.
  elim H.
  intros.
  exact (bijection B A B_to_A0 A_to_B0 B_A_B0 A_B_A0).
Qed.




(* Task 1-3. Prove that iso is transitive. *)
Theorem iso_trans : forall A B C : Set, iso A B -> iso B C -> iso A C.
Proof.
  intros.
  case H as [AB BA ABA BAB].
  case H0 as [BC CB BCB CBC].
  apply (bijection A C (fun a => BC (AB a)) (fun c =>  BA (CB c))).
  intros.
  specialize (BCB (AB a)).
  rewrite BCB.
  specialize (ABA a).
  rewrite ABA.
  reflexivity.
  intros.
  specialize (BAB (CB b)).
  rewrite BAB.
  specialize (CBC b).
  rewrite CBC.
  reflexivity.
Qed.


(* Task 1-4. Prove the following statement:
  Given two functions A->B and B->A, if A->B->A is satisfied and B->A is injective, A <=> B. *)
Theorem bijection_alt : forall (A B : Set) (A2B : A -> B) (B2A : B -> A),
  (forall a, B2A (A2B a) = a) -> (forall b1 b2, B2A b1 = B2A b2 -> b1 = b2) -> iso A B.
Proof.
  intros.
  apply (bijection _ _ A2B B2A).
  assumption.
  intros.
  rewrite (H0 (A2B (B2A b)) b).
  reflexivity.
  rewrite (H (B2A b)).
  reflexivity.
Qed.

(******************************************)
(* Task 2 : iso relations between nat and various supersets of nat *)

(* nat_plus_1 : a set having one more element than nat. (provided in preloaded) *)
(* Inductive nat_plus_1 : Set := null | is_nat (n : nat). *)

(* Task 2-1. Prove that nat has the same cardinality as nat_plus_1. *)

Inductive nat_plus_1 : Set := null | is_nat (n : nat).

Theorem nat_iso_natp1 : iso nat nat_plus_1.
Proof.
  apply (bijection _ _ (fun n => match n with
                                | 0 => null
                                | S m => is_nat m
                       end) (fun n => match n with
                                | null => 0
                                | is_nat m => S m
                       end)).
  intros.
  induction a;
  reflexivity.
  induction b;
  reflexivity.
Qed.

(* nat_plus_nat : a set having size(nat) more elements than nat. (provided in preloaded) *)
Inductive nat_plus_nat : Set := left (n : nat) | right (n : nat).

Fixpoint nat_to_nn (n : nat) : nat_plus_nat
  := match n with
       | 0 => left 0
       | 1 => right 0
       | S (S m) => match nat_to_nn m with
                     | left a => left (S a)
                     | right a => right (S a)
                    end
     end.

Definition nn_to_nat (n : nat_plus_nat) : nat
  := match n with
       | left l => l + l
       | right r => S (r + r)
     end.

Definition nat_ind_two : forall P, 
  P 0 -> P 1 -> (forall n, P n -> P (S (S n))) -> (forall n, P n).
Proof.
  intros P P0 P1 PSS.
  exact (fix go (n:nat): P n := match n with
    | 0 => P0
    | 1 => P1
    | S (S n_bez_dvou) => PSS n_bez_dvou (go n_bez_dvou)
  end
  ).
Qed.

Definition nat_ind_two2 : forall P, 
  P 0 -> P 1 -> (forall n, P n -> P (S (S n))) -> (forall n, P n).
Proof.
  intros P P0 P1 PSS.
  fix IPn 1.
  intro m.
  destruct m.
  exact P0.
  destruct m.
  exact P1.
  apply PSS.
  exact (IPn m).
Qed.


(* Task 2-2. Prove that nat has the same cardinality as nat_plus_nat. *)
Theorem nat_iso_natpnat : iso nat nat_plus_nat.
Proof.
  apply (bijection _ _ nat_to_nn nn_to_nat).
  - intros.
    induction a using nat_ind_two.
    compute. easy.
    compute. easy.
    simpl.
    destruct (nat_to_nn a).
    simpl in IHa.
    simpl.
    lia.
    simpl in IHa.
    simpl.
    lia.
  - intros.
    destruct b. 
    simpl.
    induction n.
    compute.
    reflexivity.
    assert (S n + S n = S (S (n + n))) by lia.
    rewrite -> H.
    simpl.
    rewrite -> IHn.
    reflexivity.
    simpl nn_to_nat.
    induction n.
    compute.
    reflexivity.
    simpl.
    assert (n + S n = S (n + n)) by lia.
    rewrite -> H.
    rewrite -> IHn.
    reflexivity.
Qed.















