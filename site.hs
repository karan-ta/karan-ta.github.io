--------------------------------------------------------------------------------
{-# LANGUAGE OverloadedStrings #-}
import           Control.Monad (forM_, forM, liftM)
import           Data.Monoid (mappend, mconcat)
import           Data.Monoid           ((<>))
import           Data.Maybe
import qualified Data.Map as M
import           Hakyll
import           Data.List              (isSuffixOf, isPrefixOf, isInfixOf,
                                         intercalate, sort)
import           System.FilePath.Posix  (takeBaseName, takeDirectory,
                                         (</>), takeFileName)
import           Text.Blaze.Html                 (toHtml, toValue, (!))
import           Text.Blaze.Html.Renderer.String (renderHtml)
import qualified Text.Blaze.Html5                as H
import qualified Text.Blaze.Html5.Attributes     as A
import           Data.Time
--------------------------------------------------------------------------------
host :: String
-- host = "http://karanahuja.in"
host = "http://localhost:8000/"

siteName :: String
siteName = "Karan Ahuja - The Free Geek."


options =[("googleAnalytics", "")
    , ("twitter_username", "karan_ta")
    , ("bing_verification", "")
    , ("google_verification", "")
    , ("enable_mathjax", "")
    , ("show_sharing_icons", "")
    , ("show_social_icons", "")
    , ("extended_fonts", "")
    , ("author", "karan ahuja")
    , ("description", "Karan Ahuja - The Free Geek. I share my invention journey with all of you.")
    , ("baseurl", "/")
    , ("og_locale", "en_US")
    , ("site_url", host)
    , ("og_locale", "en_US")
    , ("site_animated", "")
    , ("google_tag_manager", "")
    , ("facebook_comments", "")
    , ("facebook_appid", "")
    , ("facebook_comments_number", "10")
    , ("github_username", "karan-ta")
    , ("bitbucket_username", "")
    , ("stackoverflow_id", "")
    , ("twitter_username", "karan_ta")
    , ("skype_username", "karanahuja2015")
    , ("steam_nickname", "")
    , ("google_plus_id", "")
    , ("email", "karan@kodeplay.com")
    , ("linkedin_username", "")
    , ("angellist_username", "")
    , ("medium_id", "")
    , ("bitcoin_url", "")
    , ("paypal_url", "")
    , ("flattr_button", "")
    , ("enable_anchorjs", "")
    , ("disqus_shortname", "kodeplaysite")
    , ("maintenance", "")
    , ("show_sharing_icons", "")
    , ("show_post_footers", "")
    , ("text_post_updated", "Updated")
    , ("text_index_coming_soon", "Coming soon...")
    , ("site_text_thanks", "Thanks for subscribing. I shall send you useful monthly news.")
    , ("ajaxify_contact_form", "True")
    , ("text_contact_email", "Email Address")
    , ("text_contact_submit", "Subscribe To Monthly Newsletter.")
    , ("text_contact_ajax_sending", "sending..")
    , ("text_contact_ajax_sent", "Message sent!")
    , ("text_contact_ajax_error", "Error!")
    ]

googleAnalytics :: String
googleAnalytics = ""

sourceRepository :: String
sourceRepository = "https://github.com/karan-ta/karan-ta.github.io"

myFeedConfiguration :: FeedConfiguration
myFeedConfiguration = FeedConfiguration
    { feedTitle = siteName
    , feedDescription = ""
    , feedAuthorName = "Karan Ahuja"
    , feedAuthorEmail = "karan@kodeplay.com"
    , feedRoot = host
    }

copyFiles :: [Pattern]
copyFiles = [ "static/img/*"
            , "static/js/*"
            , "static/html/404.html"
            , "CNAME"
            , "robots.txt"
            , "favicon.ico"
            , ".htaccess"
            ]

config :: Configuration
config = defaultConfiguration
    { deployCommand = "./scripts/deploy-cmd.sh"
    , ignoreFile = ignoreFile'
    }

    where
        ignoreFile' path
            | "~" `isPrefixOf` fileName = True
            | ".#" `isPrefixOf` fileName = True
            | "~" `isSuffixOf` fileName = True
            | ".swp" `isSuffixOf` fileName = True
            | ".git" `isInfixOf` path = True
            | "_cache" `isInfixOf` path = True
            | otherwise = False
            where
                fileName = takeFileName path

main :: IO ()
main = hakyllWith config site

site :: Rules ()
site = do
  forM_ copyFiles $ \pattern->
      match pattern $ do
         route   idRoute
         compile copyFileCompiler

  match "static/css/*" $ do
         route   idRoute
         compile compressCssCompiler

  tags <- buildTags "posts/*/*" (fromCapture "tags/*.html")
  years <- buildYears "posts/*/*"
  let draftCtx = mconcat [ postSlugField "slug"
                         , postYearField "year"
                         , pageCtx ]
  let postCtx = mconcat [ tagsField "tags" tags
                        , teaserField "teaser" "content"
                        , draftCtx]

  match "drafts/*" (postRules $ draftCtx)
  match "posts/*/*" (postRules $ postCtx)

  match (fromList ["pages/newsletter.md"]) $ do
         route   $ cleanRoute `composeRoutes` (gsubRoute "pages/" (const ""))
         compile $ pandocCompiler
            >>= loadAndApplyTemplate "templates/newsletter.html" pageCtx 
            >>= saveSnapshot "content"
            >>= loadAndApplyTemplate "templates/default.html" pageCtx
            >>= relativizeUrls
            >>= cleanIndexUrls

  match "pages/*" $ do
         route   $ cleanRoute `composeRoutes` (gsubRoute "pages/" (const ""))
         compile $ pandocCompiler        
            >>= loadAndApplyTemplate "templates/page.html" pageCtx
            >>= saveSnapshot "content"
            >>= loadAndApplyTemplate "templates/default.html" pageCtx
            >>= relativizeUrls
            >>= cleanIndexUrls

  create ["index.html"] $ do
         route   idRoute
         compile $ do
           posts <- fmap (take 7) . recentFirst =<< loadAll "posts/*/*"
           let indexCtx = mconcat
                          [ listField "posts" postCtx (return posts)
                          , constField "title" "Recent posts"
                          , field "tags" (\_ -> renderTagCloud 100 300 tags)
                          , field "years" (\_ -> renderYears years)
                          , myCtx
                          ]

           makeItem ""
            >>= loadAndApplyTemplate "templates/index.html" indexCtx
            >>= loadAndApplyTemplate "templates/default.html" indexCtx
            >>= relativizeUrls
            >>= cleanIndexUrls

  forM_ years $ \(year, _)->
      create [yearId year] $ do
         route   idRoute
         compile $ do
           posts <- recentFirst =<< loadAll (fromGlob $ "posts/" ++ year ++"/*")
           let postsCtx = mconcat
                          [ listField "posts" postCtx (return posts)
                          , constField "title" ("Posts published in " ++ year)
                          , field "years" (\_ -> renderYears years)
                          , myCtx
                          ]
           makeItem ""
            >>= loadAndApplyTemplate "templates/posts.html" postsCtx
            >>= loadAndApplyTemplate "templates/default.html" postsCtx
            >>= relativizeUrls
            >>= cleanIndexUrls

  tagsRules tags $ \tag pattern -> do
         -- Copied from posts, need to refactor
         route cleanRoute
         compile $ do
           posts <- recentFirst =<< loadAll pattern
           let postsCtx = mconcat
                          [ listField "posts" postCtx (return posts)
                          , constField "title" ("Posts tagged " ++ tag)
                          , field "years" (\_ -> renderYears years)
                          , myCtx
                          ]

           makeItem ""
            >>= loadAndApplyTemplate "templates/posts.html" postsCtx
            >>= loadAndApplyTemplate "templates/default.html" postsCtx
            >>= relativizeUrls
            >>= cleanIndexUrls

  pag <- buildPaginateWith grouper "posts/*" makeId

  paginateRules pag $ \pageNum pattern -> do
      route idRoute
      compile $ do
          posts <- recentFirst =<< loadAll pattern
          let paginateCtx = paginateContext pag pageNum
              postsCtx = 
                  constField "title" ("Posts Archive - Page " ++ (show pageNum)) <>
                  listField "posts" postCtx (return posts) <>
                  paginateCtx <>
                  defaultContext
          makeItem ""
            >>= loadAndApplyTemplate "templates/posts.html" postsCtx
            >>= loadAndApplyTemplate "templates/default.html" postsCtx
            >>= relativizeUrls
            >>= cleanIndexUrls

  create ["sitemap.xml"] $ do
         route   idRoute
         compile $ do
           posts <- recentFirst =<< loadAll "posts/*/*"
           pages <- loadAll "pages/*"

           let allPosts = (return (pages ++ posts))
           let sitemapCtx = mconcat
                            [ listField "entries" pageCtx allPosts
                            , constField "host" host
                            , myCtx
                            ]

           makeItem ""
            >>= loadAndApplyTemplate "templates/sitemap.xml" sitemapCtx
            >>= cleanIndexHtmls

  create ["feed.xml"] $ do
         route   idRoute
         compile $ do
           let feedCtx = pageCtx `mappend` bodyField "description"
           posts <- fmap (take 10) . recentFirst =<<
                   loadAllSnapshots "posts/*/*" "content"
           renderAtom myFeedConfiguration feedCtx posts
             >>= cleanIndexHtmls

  match "templates/*" $ compile templateCompiler
  match "_includes/*" $ compile templateCompiler
  match "menus/*" $ compile pandocCompiler

--------------------------------------------------------------------------------

customSettings = map (uncurry constField) $ filter (\(x, y) -> y > "") options

settingsContext = customSettings ++ [
    constField "superTitle" $ stripTags siteName
    , listField "menus" myCtx $ loadAll "menus/*.md"    
    , defaultContext
    ]

myCtx :: Context String
myCtx = mconcat settingsContext

pageCtx :: Context String
pageCtx = mconcat
    [ modificationTimeField "mtime" "%U"
    , modificationTimeField "lastmod" "%Y-%m-%d"
    , dateField "updated" "%Y-%m-%dT%H:%M:%SZ"
    , constField "host" host
    , constField "source" sourceRepository
    , dateField "date" "%B %e, %Y"
    , myCtx
    ]

postRules :: Context String -> Rules ()
postRules ctx = do
    route   $ postCleanRoute
    compile $ pandocCompiler
       >>= loadAndApplyTemplate "templates/post-content.html" ctx
       >>= saveSnapshot "content"
       >>= loadAndApplyTemplate "templates/post.html" ctx
       >>= loadAndApplyTemplate "templates/default.html" ctx
       >>= relativizeUrls
           >>= cleanIndexUrls

-- custom routes
--------------------------------------------------------------------------------
postCleanRoute :: Routes
postCleanRoute = cleanRoute
 `composeRoutes` (gsubRoute "(posts/[0-9]{4}/|drafts/)" (const ""))

cleanRoute :: Routes
cleanRoute = customRoute createIndexRoute
  where
    createIndexRoute ident = takeDirectory p </> takeBaseName p </> "index.html"
                            where p = toFilePath ident

cleanIndexUrls :: Item String -> Compiler (Item String)
cleanIndexUrls = return . fmap (withUrls cleanIndex)

cleanIndexHtmls :: Item String -> Compiler (Item String)
cleanIndexHtmls = return . fmap (replaceAll pattern replacement)
    where
      pattern = "/index.html"
      replacement = const "/"

cleanIndex :: String -> String
cleanIndex url
    | idx `isSuffixOf` url = take (length url - length idx) url
    | otherwise            = url
  where idx = "index.html"

-- utils
--------------------------------------------------------------------------------

type Year = String

buildYears :: MonadMetadata m => Pattern -> m [(Year, Int)]
buildYears pattern = do
    ids <- getMatches pattern
    return . frequency . (map getYear) $ ids
  where
    frequency xs =  M.toList (M.fromListWith (+) [(x, 1) | x <- xs])

postSlugField :: String -> Context a
postSlugField key = field key $ return . baseName
  where baseName = takeBaseName . toFilePath . itemIdentifier

postYearField :: String -> Context a
postYearField key = field key $ return . getYear . itemIdentifier

getYear :: Identifier -> Year
getYear = takeBaseName . takeDirectory . toFilePath

yearPath :: Year -> FilePath
yearPath year = "archive/" ++ year ++ "/index.html"

yearId :: Year -> Identifier
yearId = fromFilePath . yearPath

renderYears :: [(Year, Int)] -> Compiler String
renderYears years = do
  years' <- forM (reverse . sort $ years) $ \(year, count) -> do
      route' <- getRoute $ yearId year
      return (year, route', count)
  return . intercalate ", " $ map makeLink years'

  where
    makeLink (year, route', count) =
      (renderHtml (H.a ! A.href (yearUrl year) $ toHtml year)) ++
      " (" ++ show count ++ ")"
    yearUrl = toValue . toUrl . yearPath


makeId :: PageNumber -> Identifier
makeId pageNum = fromFilePath $ "blog/page/" ++ (show pageNum) ++ "/index.html"

-- Run sortRecentFirst on ids, and then liftM (paginateEvery 10) into it
grouper :: MonadMetadata m => [Identifier] -> m [[Identifier]]
grouper ids = (liftM (paginateEvery 10) . sortRecentFirst) ids