{-# OPTIONS_GHC -fglasgow-exts #-}
{-# LANGUAGE OverlappingInstances,UndecidableInstances #-}

module Data.Has.Engine where

import Data.Has.TypeList

-- | @Row a@ is a type list which contains only one element of
--   @a@. And every row in the records should be this type.
type Row a = a ::: TyNil

-- | Creates a 'Row' of @a@.
row :: a -> Row a
row a = a ::: TyNil

-- | Concatenates between 'Row's or records. Records means
--   concatenations of rows. For example, Following expressions are
--   valid.
--
-- > -- Concatenation of rows (i.e. record)
-- > row "string" & row True
--
-- > -- Concatenation of records
-- > (row 'c' & row ()) & (row False & row "string")
--
-- > -- ... And concatenations between a row and a record
-- > row () & (row False & row "string")
-- > (row 'c' & row ()) & row False
(&) :: (Append a b) => a -> b -> a :&: b
(&) = (.++.)
infixr 5 &

-- | Represents concatenated rows or records.
type family a :&: b
type instance a :&: b = a :++: b
infixr 5 :&:

-- | Provides plient function. Holds @e == prj (inj e s)@ for all @s@ and @e@.
class Has e s where
    -- | Injects a value of type @e@ into @s@ if @s@ contains the type @e@.
    inj :: e -> s -> s
    -- | Projects a value of type @e@ out from @s@ if @s@ contains the type @e@.
    prj :: s -> e

instance Has e (e ::: r) where
    inj e ~(e' ::: r) = e ::: r
    prj   ~(e' ::: r) = e'
instance Has e r => Has e (h ::: r) where
    inj e ~(h ::: r) = h ::: inj e r
    prj   ~(h ::: r) = prj r
