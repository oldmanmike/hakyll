-- | An identifier is a type used to uniquely identify a resource, target...
--
-- One can think of an identifier as something similar to a file path. An
-- identifier is a path as well, with the different elements in the path
-- separated by @/@ characters. Examples of identifiers are:
--
-- * @posts/foo.markdown@
--
-- * @index@
--
-- * @error/404@
--
-- The most important difference between an 'Identifier' and a file path is that
-- the identifier for an item is not necesserily the file path.
--
-- For example, we could have an @index@ identifier, generated by Hakyll. The
-- actual file path would be @index.html@, but we identify it using @index@.
--
-- @posts/foo.markdown@ could be an identifier of an item that is rendered to
-- @posts/foo.html@. In this case, the identifier is the name of the source
-- file of the page.
--
{-# LANGUAGE GeneralizedNewtypeDeriving, DeriveDataTypeable #-}
module Hakyll.Core.Identifier
    ( Identifier (..)
    , parseIdentifier
    , toFilePath
    , setGroup
    ) where

import Control.Arrow (second)
import Control.Applicative ((<$>), (<*>))
import Control.Monad (mplus)
import Data.Monoid (Monoid, mempty, mappend)
import Data.List (intercalate)

import Data.Binary (Binary, get, put)
import GHC.Exts (IsString, fromString)
import Data.Typeable (Typeable)

-- | An identifier used to uniquely identify a value
--
data Identifier = Identifier
    { identifierGroup :: Maybe String
    , identifierPath  :: String
    } deriving (Eq, Ord, Typeable)

instance Monoid Identifier where
    mempty = Identifier Nothing ""
    Identifier g1 p1 `mappend` Identifier g2 p2 =
        Identifier (g1 `mplus` g2) (p1 `mappend` p2)

instance Binary Identifier where
    put (Identifier g p) = put g >> put p
    get = Identifier <$> get <*> get

instance Show Identifier where
    show = toFilePath

instance IsString Identifier where
    fromString = parseIdentifier

-- | Parse an identifier from a string
--
parseIdentifier :: String -> Identifier
parseIdentifier = Identifier Nothing
                . intercalate "/" . filter (not . null) . split'
  where
    split' [] = [[]]
    split' str = let (pre, post) = second (drop 1) $ break (== '/') str
                 in pre : split' post

-- | Convert an identifier to a relative 'FilePath'
--
toFilePath :: Identifier -> FilePath
toFilePath = identifierPath

-- | Set the identifier group for some identifier
--
setGroup :: Maybe String -> Identifier -> Identifier
setGroup g (Identifier _ p) = Identifier g p
