<?php
/**
 * Smarty Extension class
 *
 * PHP version 5
 *
 * Copyright (C) Villanova University 2007.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 2,
 * as published by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 *
 * @category VuFind
 * @package  Support_Classes
 * @author   Andrew S. Nagy <vufind-tech@lists.sourceforge.net>
 * @license  http://opensource.org/licenses/gpl-2.0.php GNU General Public License
 * @link     http://vufind.org/wiki/system_classes Wiki
 */
require_once 'Smarty/Smarty.class.php';
require_once 'sys/mobile_device_detect.php';
require_once 'sys/Cart_Model.php';

/**
 * Smarty Extension class
 *
 * @category VuFind
 * @package  Support_Classes
 * @author   Andrew S. Nagy <vufind-tech@lists.sourceforge.net>
 * @license  http://opensource.org/licenses/gpl-2.0.php GNU General Public License
 * @link     http://vufind.org/wiki/system_classes Wiki
 */
class UInterface extends Smarty
{
    public $lang;
    private $_vufindTheme;   // which theme(s) are active?

    /**
     * Constructor
     *
     * @access public
     */
    public function UInterface()
    {
        global $configArray;

        $local = $configArray['Site']['local'];
        $this->_vufindTheme = $configArray['Site']['theme'];

        // Use mobile theme for mobile devices (if enabled in config.ini)
        if (isset($configArray['Site']['mobile_theme'])) {
            // If the user is overriding the UI setting, store that:
            if (isset($_GET['ui'])) {
                $_COOKIE['ui'] = $_GET['ui'];
                setcookie('ui', $_GET['ui'], null, '/');
            } else if (!isset($_COOKIE['ui'])) {
                // If we don't already have a UI setting, detect if we're on a
                // mobile device and store the result in a cookie so we don't waste
                // time doing the detection routine on every page:
                $_COOKIE['ui'] = mobile_device_detect() ? 'mobile' : 'standard';
                setcookie('ui', $_COOKIE['ui'], null, '/');
            }
            // If we're mobile, override the standard theme with the mobile one:
            if ($_COOKIE['ui'] == 'mobile') {
                $this->_vufindTheme = $configArray['Site']['mobile_theme'];
            }
        }

        // Check to see if multiple themes were requested; if so, build an array,
        // otherwise, store a single string.
        $themeArray = explode(',', $this->_vufindTheme);
        if (count($themeArray) > 1) {
            $this->template_dir = array();
            foreach ($themeArray as $currentTheme) {
                $currentTheme = trim($currentTheme);
                $this->template_dir[] = "$local/interface/themes/$currentTheme";
            }
        } else {
            $this->template_dir  = "$local/interface/themes/{$this->_vufindTheme}";
        }

        // Create an MD5 hash of the theme name -- this will ensure that it's a
        // writeable directory name (since some config.ini settings may include
        // problem characters like commas or whitespace).
        $md5 = md5($this->_vufindTheme);
        $this->compile_dir   = "$local/interface/compile/$md5";
        if (!is_dir($this->compile_dir)) {
            mkdir($this->compile_dir);
        }
        $this->cache_dir     = "$local/interface/cache/$md5";
        if (!is_dir($this->cache_dir)) {
            mkdir($this->cache_dir);
        }
        $this->plugins_dir   = array('plugins', "$local/interface/plugins");
        $this->caching       = false;
        $this->debug         = true;
        $this->compile_check = true;

        unset($local);

        $this->register_function('translate', 'translate');
        $this->register_function('char', 'char');

        $this->assign('site', $configArray['Site']);
        $this->assign('path', $configArray['Site']['path']);
        $this->assign('url', $configArray['Site']['url']);
        $this->assign(
            'fullPath',
            isset($_SERVER['REQUEST_URI']) ? $_SERVER['REQUEST_URI'] : false
        );
        $this->assign('supportEmail', $configArray['Site']['email']);
        /* begin of costumization for MZK */
        $searchObject = SearchObjectFactory::initSearchObject();
        /* end of costumization for MZK */
        $this->assign(
            'basicSearchTypes',
            is_object($searchObject) ? $searchObject->getBasicTypes() : array()
        );
        $this->assign(
            'autocomplete',
            is_object($searchObject) ? $searchObject->getAutocompleteStatus() : false
        );
        $this->assign(
            'retainFiltersByDefault', $searchObject->getRetainFilterSetting()
        );

        if (isset($configArray['Site']['showBookBag'])) {
            $this->assign(
                'bookBag', ($configArray['Site']['showBookBag'])
                ? Cart_Model::getInstance() : false
            );
        }

        if (isset($configArray['OpenURL'])
            && isset($configArray['OpenURL']['url'])
        ) {
            // Trim off any parameters (for legacy compatibility -- default config
            // used to include extraneous parameters):
            list($base) = explode('?', $configArray['OpenURL']['url']);
        } else {
            $base = false;
        }
        $this->assign('openUrlBase', empty($base) ? false : $base);

        // Other OpenURL settings:
        $this->assign(
            'openUrlWindow',
            empty($configArray['OpenURL']['window_settings'])
            ? false : $configArray['OpenURL']['window_settings']
        );
        $this->assign(
            'openUrlGraphic',
            empty($configArray['OpenURL']['graphic'])
            ? false : $configArray['OpenURL']['graphic']
        );
        $this->assign(
            'openUrlGraphicWidth',
            empty($configArray['OpenURL']['graphic_width'])
            ? false : $configArray['OpenURL']['graphic_width']
        );
        $this->assign(
            'openUrlGraphicHeight',
            empty($configArray['OpenURL']['graphic_height'])
            ? false : $configArray['OpenURL']['graphic_height']
        );
        if (isset($configArray['OpenURL']['embed'])
            && !empty($configArray['OpenURL']['embed'])
        ) {
            include_once 'sys/Counter.php';
            $this->assign('openUrlEmbed', true);
            $this->assign('openUrlCounter', new Counter());
        }

        $this->assign('currentTab', 'Search');

        $this->assign('authMethod', $configArray['Authentication']['method']);

        if ($configArray['Authentication']['method'] == 'Shibboleth') {
            if (!isset($configArray['Shibboleth']['login'])
                || !isset($configArray['Shibboleth']['target'])
            ) {
                throw new Exception(
                    'Missing parameter in the config.ini. Check if ' .
                    'the parameters login and target are set.'
                );
            }
            $site_url = $configArray['Site']['url'];
            $shib_target = $configArray['Shibboleth']['target'];
            if ($shib_target[0] == '/') {
                $shib_target = $site_url . $shib_target;
            }
            $url = urlencode($shib_target . "?redirect=".
                urlencode("https://" . $_SERVER['SERVER_NAME'] . $_SERVER['REQUEST_URI']));
            $shib_login = $configArray['Shibboleth']['login'];
            if ($shib_login[0] == '/') {
                $sessionInitiator = $site_url . $shib_login . "?target=$url";
            } else {
                $sessionInitiator = $configArray['Shibboleth']['login'] . "?target=$url";
            }
            if (isset($configArray['Shibboleth']['provider_id'])) {
                $sessionInitiator = $sessionInitiator . '&providerId=' .
                    $configArray['Shibboleth']['provider_id'];
            }

            $this->assign('sessionInitiator', $sessionInitiator);
            $this->assign('currentURL', "https://" . $_SERVER['SERVER_NAME'] . $_SERVER['REQUEST_URI']); // modification for MZK
        }

        $this->assign(
            'sidebarOnLeft',
            !isset($configArray['Site']['sidebarOnLeft'])
            ? false : $configArray['Site']['sidebarOnLeft']
        );

        $catalog = ConnectionManager::connectToCatalog();
        $this->assign("offlineMode", $catalog->getOfflineMode());
        $hideLogin = isset($configArray['Authentication']['hideLogin'])
            ? $configArray['Authentication']['hideLogin'] : false;
        $this->assign("hideLogin", $hideLogin ? true : $catalog->loginIsHidden());
    }

    /**
     * Get the current active theme setting.
     *
     * @return string
     * @access public
     */
    public function getVuFindTheme()
    {
        return $this->_vufindTheme;
    }

    /**
     * Set the inner page template to display.
     *
     * @param string $tpl Template filename.
     *
     * @return void
     * @access public
     */
    public function setTemplate($tpl)
    {
        $this->assign('pageTemplate', $tpl);
    }

    /**
     * Set the page title to display.
     *
     * @param string $title Page title.
     *
     * @return void
     * @access public
     */
    public function setPageTitle($title)
    {
        $this->assign('pageTitle', translate($title));
    }

    /**
     * Get the currently selected language code.
     *
     * @return string
     * @access public
     */
    public function getLanguage()
    {
        return $this->lang;
    }

    /**
     * Set the currently selected language code.
     *
     * @param string $lang Language code.
     *
     * @return void
     * @access public
     */
    public function setLanguage($lang)
    {
        global $configArray;

        $this->lang = $lang;
        $this->assign('userLang', $lang);
        $this->assign('allLangs', $configArray['Languages']);
    }

    /**
     * Initialize global interface variables (part of standard VuFind startup
     * process).  This method is designed for initializations that can't happen
     * in the constructor because they rely on session initialization and other
     * processing that happens subsequently in the front controller.
     *
     * @return void
     * @access public
     */
    public function initGlobals()
    {
        global $module, $action, $user, $configArray;

        // Pass along module and action to the templates.
        $this->assign('module', $module);
        $this->assign('action', $action);
        $this->assign('user', $user);

        // Load the last limit from the request or session for initializing default
        // in search box:
        if (isset($_REQUEST['limit'])) {
            $this->assign('lastLimit', $_REQUEST['limit']);
        } else if (isset($_SESSION['lastUserLimit'])) {
            $this->assign('lastLimit', $_SESSION['lastUserLimit']);
        }

        // Load the last sort from the request or session for initializing default
        // in search box.  Note that this is not entirely ideal, since sort settings
        // will carry over from one module to another (i.e. WorldCat vs. Summon);
        // however, this is okay since the validation code will prevent errors and
        // simply revert to default sort when switching between modules.
        if (isset($_REQUEST['sort'])) {
            $this->assign('lastSort', $_REQUEST['sort']);
        } else if (isset($_SESSION['lastUserSort'])) {
            $this->assign('lastSort', $_SESSION['lastUserSort']);
        }

        // This is detected already, but we want a "back to mobile"
        // button in the standard view on mobile devices so we check it again
        if (isset($configArray["Site"]["mobile_theme"]) && mobile_device_detect()) {
            $pageURL = $_SERVER['REQUEST_URI'];
            if (isset($_GET["ui"])) {
                $pageURL = str_replace(
                    "ui=" . urlencode($_GET["ui"]), "ui=mobile", $pageURL
                );
            } else if (strstr($pageURL, "?") != false) {
                $pageURL = str_replace("?", "?ui=mobile&", $pageURL);
            } else if (strstr($pageURL, "#") != false) {
                $pageURL = str_replace("#", "?ui=mobile#", $pageURL);
            } else {
                $pageURL .= "?ui=mobile";
            }
            $this->assign("mobileViewLink", $pageURL);
        }
        if (isset($configArray['GoogleAnalytics'])) {
            $this->assign('googleAnalytics', $configArray['GoogleAnalytics']);
            /* begin of costumization for MZK */
            // google analytics
            $firstload = !isset($_SESSION['firstload']);
            if ($firstload) {
                if ($_GET['logout']) {
                    $firstload = false;
                }
                $_SESSION['firstload'] = false;
            }
            $gaVars = array();
            if ($firstload) {
                $ips = array(
                    '195.113.155.102' => 'employee',
                    '195.113.155.3' => 'inside',
                    '195.113.155.9' => 'inside',
                    '195.113.155.33' => 'inside',
                );
                $visitorType = $ips[$_SERVER['REMOTE_ADDR']];
                if (!isset($visitorType)) {
                    $visitorType = 'outside';
                }
                $gaVars['visitorType'] = array('index' => 1, 'value' => $visitorType, 'type' => 1);
                $gaVars['visitorStatus'] = array('index' => 2, 'value' => 'anonymous', 'type' => 1);
            }
            if (UserAccount::isLoggedIn()) {
                $gaVars['visitorStatus'] = array('index' => 2, 'value' => 'logged-in', 'type' => 1);
            }
            $this->assign('googleAnalyticsVariables', $gaVars);
            // new items link
            $curr_date = date('Ym', strtotime('now'));
            $this->assign('newItemsLink', "acq_int:[$curr_date TO $curr_date]");
            /* end of costumizaton for MZK */
        }
    }

    /**
     * Assign book preview options to the interface.
     *
     * @return void
     */
    public function assignPreviews()
    {
        global $configArray;
        global $interface;

        $providers = explode(',', $configArray['Content']['previews']);
        $interface->assign('showPreviews', true);
        foreach ($providers as $provider) {
            $provider = trim($provider);
            switch ($provider) {
            case 'Google':
                // fetch Google options from config, if none use default vals.
                $googleOptions = isset($configArray['Content']['GoogleOptions'])
                    ? str_replace(' ', '', $configArray['Content']['GoogleOptions'])
                    : "full,partial";
                $interface->assign('googleOptions', $googleOptions);
                break;
            case 'OpenLibrary':
                // fetch OL options from config, if none use default vals.
                $olOptions = isset($configArray['Content']['OpenLibraryOptions'])
                    ? str_replace(
                        ' ', '', $configArray['Content']['OpenLibraryOptions']
                    )
                    : "full,partial";
                $interface->assign('olOptions', $olOptions);
                break;
            case 'HathiTrust':
                // fetch Hathi access rights from config (or default to pd,world)
                $hathiOptions = isset($configArray['Content']['HathiRights'])
                    ? str_replace(' ', '', $configArray['Content']['HathiRights'])
                    : "pd,world";
                $interface->assign('hathiOptions', $hathiOptions);
                break;
            }
        }
    }
}

/**
 * Smarty extension function to translate a string.
 *
 * @param string|array $params Either array from Smarty or plain string to translate
 *
 * @return string              Translated string
 */
function translate($params)
{
    global $translator;

    // If no translator exists yet, create one -- this may be necessary if we
    // encounter a failure before we are able to load the global translator
    // object.
    if (!is_object($translator)) {
        global $configArray;

        $translator = new I18N_Translator(
            'lang', $configArray['Site']['language'], $configArray['System']['debug']
        );
    }
    if (is_array($params)) {
        return $translator->translate($params['text']);
    } else {
        return $translator->translate($params);
    }
}

/**
 * Smarty extension function to generate a character from an integer.
 *
 * @param array $params Parameters passed in by Smarty
 *
 * @return string       Generated character
 */
function char($params)
{
    extract($params);
    return chr($int);
}

?>
