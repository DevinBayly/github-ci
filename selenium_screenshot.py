"""Module to take an screenshot using selenium"""
import time

from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.support.ui import WebDriverWait

# pylint: disable=import-error
from pyvirtualdisplay import Display

MAX_ATTEMPTS = 18


def strtobool(val):
    """Convert a string representation of truth to true (1) or false (0).
    True values are 'y', 'yes', 't', 'true', 'on', and '1'; false values
    are 'n', 'no', 'f', 'false', 'off', and '0'.  Raises ValueError if
    'val' is anything else.
    """
    val = val.lower()
    if val in ("y", "yes", "t", "true", "on", "1"):
        return 1
    if val in ("n", "no", "f", "false", "off", "0"):
        return 0
    raise ValueError(f"invalid truth value {val}")


def _take_screenshot(browser, file_name):
    img = browser.get_screenshot_as_png()
    with open(file_name, "wb") as image:
        image.write(img)


def _init_browser(url, width=1000, height=500):
    window_width = int(width) if width is not None else 1000
    window_height = int(height) if height is not None else 500
    display = Display(visible=0, size=(1366, 768))
    display.start()

    chrome_options = webdriver.ChromeOptions()
    chrome_options.add_argument("--no-sandbox")
    chrome_options.add_argument("--disable-dev-shm-usage")

    chrome_options.add_experimental_option("excludeSwitches", ["enable-automation"])
    chrome_options.add_experimental_option(
        "prefs", {"download.prompt_for_download": False}
    )
    browser = webdriver.Chrome(options=chrome_options)
    browser.set_window_size(window_width, window_height)
    browser.get(url)

    return browser


def resize_chromium_viewport(browser, width, height, app_selector_xpath):
    """
    Change the viewport value of  iframe content only when the document has just one
    Keyword arguments:
    browser -- Selenium browser instance
    height -- Browser height
    """
    window_height = int(height) if height is not None else 500
    window_width = int(width) if width is not None else 1000
    # Run javasript script to get the iframe's body height
    # pylint: disable=line-too-long
    new_height = browser.execute_script(
        """
        // Find the target content using XPath
        var targetNode = document.evaluate(arguments[1], document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue;
        if (!targetNode) return arguments[0];
        var iframes = targetNode.querySelectorAll('iframe');
        if (iframes.length === 1) {
            var canvas = iframes[0];
            return canvas.contentDocument.body.scrollHeight;
        }
        var VERTICAL_MARGIN = 16;
        return Math.max(arguments[0], document.body.scrollHeight + VERTICAL_MARGIN);
    """,
        window_height,
        app_selector_xpath,
    )

    if window_height != new_height:
        # Append a custom command with current browser session
        # pylint: disable=protected-access
        browser.command_executor._commands["send_command"] = (
            "POST",
            "/session/{0}/chromium/send_command".format(browser.session_id),
        )
        # Emulation.setDeviceMetricsOverride is a command which allows us to change the viewport size
        params = {
            "cmd": "Emulation.setDeviceMetricsOverride",
            "params": {
                "mobile": False,
                "width": window_width,
                "height": max(new_height, window_height),
                "deviceScaleFactor": 1,
                "screenOrientation": {"angle": 0, "type": "portraitPrimary"},
            },
        }
        # Run custom command
        browser.execute("send_command", params)


def _take_selenium_screenshot_validate_load(
    url, file_name, width=1000, height=500, **kwargs
):
    """Take an screenshot using selenium
    Keyword arguments:
    url -- URL Page to take the screenshot
    file_name -- Image path name
    width -- Browser width. Default 1000
    height -- Browser height. Default 500
    app_selector_xpath -- Target content XPath selector
    not_load_selector_xpath -- XPath selector to identify an empty page
    timeout -- The time to wait until the content load
    """
    app_selector_xpath = kwargs.get("app_selector_xpath", "//div[@id='root']")
    loading_selector_xpath = kwargs.get(
        "loading_selector_xpath", "//div[contains(@class, 'selenium-data-loading')]"
    )
    not_load_selector_xpath = kwargs.get(
        "not_load_selector_xpath", "//div[contains(@class, 'selenium-data-not-loaded')]"
    )
    timeout = int(kwargs.get("timeout", 10))
    # Init chromium
    browser = _init_browser(url, width, height)

    # Wait until the root element is loaded. Value in seconds
    WebDriverWait(browser, timeout).until(
        EC.presence_of_element_located((By.XPATH, app_selector_xpath))
    )

    for _ in range(MAX_ATTEMPTS):
        time.sleep(timeout)
        loading_elements = browser.find_elements_by_xpath(loading_selector_xpath)
        if len(loading_elements) == 0:
            break
    # Check if the element is empty
    empty_elements = browser.find_elements_by_xpath(not_load_selector_xpath)

    # check if loading element is empty

    loading_elements = browser.find_elements_by_xpath(loading_selector_xpath)

    if len(empty_elements) > 0 or len(loading_elements) > 0:
        raise ValueError(
            f"Data was not loaded, selection {not_load_selector_xpath} detected."
        )

    # Resize window for canvas widgets
    resize_chromium_viewport(browser, width, height, app_selector_xpath)

    # Wait a little bit for DOM changes
    time.sleep(2)

    # Take the screenshot
    _take_screenshot(browser, file_name)

    if browser is not None:
        browser.quit()


def _take_selenium_screenshot_validate_render(
    url, file_name, width=1000, height=500, **kwargs
):
    """Take an screenshot using selenium
    Keyword arguments:
    url -- URL Page to take the screenshot
    file_name -- Image path name
    width -- Browser width. Default 1000
    height -- Browser height. Default 500
    app_selector_xpath -- Target content XPath selector
    not_load_selector_xpath -- XPath selector to identify an empty page
    timeout -- The time to wait until the content load
    """
    app_selector_xpath = "//div[@id='root']"
    render_selector_xpath = "//div[contains(@class, 'successfully-rendered')]"
    not_load_selector_xpath = "//div[contains(@class, 'selenium-data-not-loaded')]"
    timeout = int(kwargs.get("timeout", 10))
    # Init chromium
    browser = _init_browser(url, width, height)
    # Wait until the root element is loaded. Value in seconds
    WebDriverWait(browser, timeout).until(
        EC.presence_of_element_located((By.XPATH, app_selector_xpath))
    )

    for _ in range(MAX_ATTEMPTS):
        time.sleep(timeout)
        render_elements = browser.find_elements_by_xpath(render_selector_xpath)
        if len(render_elements) != 0:
            break
    # Check if the element is empty
    empty_elements = browser.find_elements_by_xpath(not_load_selector_xpath)

    if len(empty_elements) != 0 or len(render_elements) == 0:
        raise ValueError(
            f"Data was not loaded, selection {not_load_selector_xpath} detected."
        )

    # Resize window for canvas widgets
    resize_chromium_viewport(browser, width, height, app_selector_xpath)
    # Wait a little bit for DOM changes
    time.sleep(2)
    # Take the screenshot
    _take_screenshot(browser, file_name)

    if browser is not None:
        browser.quit()


def take_selenium_screenshot(url, file_name, width=1000, height=500, **kwargs):
    if kwargs.pop("validate_render", False):
        return _take_selenium_screenshot_validate_render(
            url, file_name, width=width, height=height, **kwargs
        )
    return _take_selenium_screenshot_validate_load(
        url, file_name, width=width, height=height, **kwargs
    )


if __name__ == "__main__":
    import sys

    PARAMS = {
        "url": sys.argv[1],
        "file_name": sys.argv[2],
        "width": sys.argv[3],
        "height": sys.argv[4],
    }
    if len(sys.argv) >= 7:
        PARAMS.update(
            {"app_selector_xpath": sys.argv[5], "not_load_selector_xpath": sys.argv[6]}
        )

    if len(sys.argv) >= 8:
        PARAMS.update({"timeout": sys.argv[7]})

    if len(sys.argv) >= 9:
        PARAMS.update({"validate_render": strtobool(sys.argv[8])})

    take_selenium_screenshot(**PARAMS)