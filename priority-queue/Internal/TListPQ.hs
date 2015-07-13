
module Internal.TListPQ(
    TListPQ
) where

import Data.Functor((<$>))
import Control.Concurrent.STM
import PriorityQueue

data TNode k v = TNil
               | TCons k v (TVar (TNode k v))

data TListPQ k v = TLPQ (TVar (TNode k v))


tlpqNew :: STM (TListPQ k v)
tlpqNew = TLPQ <$> newTVar TNil


tlpqInsert :: (Ord k) => TListPQ k v -> k -> v -> STM ()
tlpqInsert (TLPQ hd) k v =
    do
        xs <- readTVar hd
        xs' <- push xs
        writeTVar hd xs'
    where
        push TNil                 = TCons k v <$> newTVar TNil
        push cur@(TCons k' _ nxt) = do
          if k' > k then TCons k v <$> newTVar cur
          else do
            next <- readTVar nxt
            nnext <- push next
            writeTVar nxt $ nnext
            return cur


tlpqPeekMin :: TListPQ k v -> STM v
tlpqPeekMin (TLPQ hd) = do
    xs <- readTVar hd
    case xs of
      TNil  -> retry
      (TCons _ v _) -> return v


tlpqDeleteMin :: TListPQ k v -> STM v
tlpqDeleteMin (TLPQ hd) = do
    xs <- readTVar hd
    case xs of
      TNil            -> retry
      (TCons _ v nxt) -> do
        next <- readTVar nxt
        writeTVar hd next
        return v


tlpqTryDeleteMin :: TListPQ k a -> STM (Maybe a)
tlpqTryDeleteMin lpq = (Just <$> tlpqDeleteMin lpq) `orElse` return Nothing


instance PriorityQueue TListPQ where
  new            = tlpqNew
  insert         = tlpqInsert
  peekMin        = tlpqPeekMin
  deleteMin      = tlpqDeleteMin
  tryDeleteMin   = tlpqTryDeleteMin

