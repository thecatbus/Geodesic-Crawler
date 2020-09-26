{-# LANGUAGE CPP #-}
{-# LANGUAGE NoRebindableSyntax #-}
{-# OPTIONS_GHC -fno-warn-missing-import-lists #-}
module Paths_Geodesic_Crawler (
    version,
    getBinDir, getLibDir, getDynLibDir, getDataDir, getLibexecDir,
    getDataFileName, getSysconfDir
  ) where

import qualified Control.Exception as Exception
import Data.Version (Version(..))
import System.Environment (getEnv)
import Prelude

#if defined(VERSION_base)

#if MIN_VERSION_base(4,0,0)
catchIO :: IO a -> (Exception.IOException -> IO a) -> IO a
#else
catchIO :: IO a -> (Exception.Exception -> IO a) -> IO a
#endif

#else
catchIO :: IO a -> (Exception.IOException -> IO a) -> IO a
#endif
catchIO = Exception.catch

version :: Version
version = Version [0,1,0,0] []
bindir, libdir, dynlibdir, datadir, libexecdir, sysconfdir :: FilePath

bindir     = "/Users/parth/.cabal/bin"
libdir     = "/Users/parth/.cabal/lib/x86_64-osx-ghc-8.8.4/Geodesic-Crawler-0.1.0.0-inplace-Geodesic-Crawler"
dynlibdir  = "/Users/parth/.cabal/lib/x86_64-osx-ghc-8.8.4"
datadir    = "/Users/parth/.cabal/share/x86_64-osx-ghc-8.8.4/Geodesic-Crawler-0.1.0.0"
libexecdir = "/Users/parth/.cabal/libexec/x86_64-osx-ghc-8.8.4/Geodesic-Crawler-0.1.0.0"
sysconfdir = "/Users/parth/.cabal/etc"

getBinDir, getLibDir, getDynLibDir, getDataDir, getLibexecDir, getSysconfDir :: IO FilePath
getBinDir = catchIO (getEnv "Geodesic_Crawler_bindir") (\_ -> return bindir)
getLibDir = catchIO (getEnv "Geodesic_Crawler_libdir") (\_ -> return libdir)
getDynLibDir = catchIO (getEnv "Geodesic_Crawler_dynlibdir") (\_ -> return dynlibdir)
getDataDir = catchIO (getEnv "Geodesic_Crawler_datadir") (\_ -> return datadir)
getLibexecDir = catchIO (getEnv "Geodesic_Crawler_libexecdir") (\_ -> return libexecdir)
getSysconfDir = catchIO (getEnv "Geodesic_Crawler_sysconfdir") (\_ -> return sysconfdir)

getDataFileName :: FilePath -> IO FilePath
getDataFileName name = do
  dir <- getDataDir
  return (dir ++ "/" ++ name)
