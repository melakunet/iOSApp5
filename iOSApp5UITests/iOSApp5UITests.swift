//
//  iOSApp5UITests.swift
//  iOSApp5UITests
//
//  Created by Etefworkie Melaku on 2026-07-08.
//

import XCTest

final class iOSApp5UITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        // Stop the whole test as soon as one step fails — there is no point running
        // later steps if the app is already in a broken state.
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // Every animal card must appear on the grid so a child can reach all 8 animals.
    // We scroll down once in case the bottom row has been pushed off screen on small devices.
    @MainActor
    func testGridShowsAllEightAnimalCards() throws {
        let scrollView = app.scrollViews.firstMatch
        XCTAssertTrue(scrollView.waitForExistence(timeout: 5), "Grid scroll view not found")

        let animalNames = ["Dog", "Cat", "Cow", "Lion", "Elephant", "Duck", "Horse", "Sheep"]
        for name in animalNames {
            if !app.staticTexts[name].exists {
                scrollView.swipeUp()
            }
            XCTAssertTrue(
                app.staticTexts[name].waitForExistence(timeout: 3),
                "\(name) card label not found on the grid"
            )
        }
    }

    // Tapping a card's name/image area should trigger the sound without crashing the app
    // or navigating away from the grid.
    @MainActor
    func testTappingCardDoesNotCrash() throws {
        let dogLabel = app.staticTexts["Dog"]
        XCTAssertTrue(dogLabel.waitForExistence(timeout: 5), "Dog card not found on grid")
        dogLabel.tap()
        // Dog's label still being on screen means the app survived the tap and stayed on the grid.
        XCTAssertTrue(
            dogLabel.waitForExistence(timeout: 3),
            "App crashed or navigated unexpectedly after tapping the Dog card"
        )
    }

    // Tapping "See more" on a card must navigate to the detail screen and show the animal
    // name in the navigation bar, the "Did you know?" section, and the "Hear me!" button.
    @MainActor
    func testDetailScreenShowsCorrectContent() throws {
        // firstMatch gives us Dog's "See more" button because Dog is first in Animal.all.
        // We use CONTAINS so the predicate works even if the SF chevron icon adds extra
        // words to the accessibility label.
        let seeMore = app.buttons
            .matching(NSPredicate(format: "label CONTAINS 'See more'"))
            .firstMatch
        XCTAssertTrue(seeMore.waitForExistence(timeout: 5), "No 'See more' button found on grid")
        seeMore.tap()

        // The navigation bar title becomes the animal name once the push completes.
        XCTAssertTrue(
            app.navigationBars["Dog"].waitForExistence(timeout: 5),
            "Detail screen navigation title 'Dog' not found after navigating"
        )

        // "Did you know?" confirms the fact section loaded on the detail screen.
        XCTAssertTrue(
            app.staticTexts["Did you know?"].waitForExistence(timeout: 3),
            "'Did you know?' label not found on the detail screen"
        )

        // The "Hear me!" button must be present so the child can replay the sound.
        XCTAssertTrue(
            app.buttons["Hear me!"].waitForExistence(timeout: 3),
            "'Hear me!' button not found on the detail screen"
        )
    }

    // Tapping "Hear me!" must trigger the sound without crashing the app.
    @MainActor
    func testHearMeButtonDoesNotCrash() throws {
        let seeMore = app.buttons
            .matching(NSPredicate(format: "label CONTAINS 'See more'"))
            .firstMatch
        XCTAssertTrue(seeMore.waitForExistence(timeout: 5))
        seeMore.tap()

        let hearMe = app.buttons["Hear me!"]
        XCTAssertTrue(hearMe.waitForExistence(timeout: 5), "'Hear me!' button not found")
        hearMe.tap()

        // If the button is still there after the tap, the app didn't crash.
        XCTAssertTrue(
            hearMe.waitForExistence(timeout: 2),
            "App crashed or button disappeared after tapping 'Hear me!'"
        )
    }

    // After tapping "See more" and viewing the detail screen, the back button must
    // bring the user back to the grid with all cards still visible.
    @MainActor
    func testNavigatingBackFromDetailReturnsToGrid() throws {
        let seeMore = app.buttons
            .matching(NSPredicate(format: "label CONTAINS 'See more'"))
            .firstMatch
        XCTAssertTrue(seeMore.waitForExistence(timeout: 5))
        seeMore.tap()

        XCTAssertTrue(app.navigationBars["Dog"].waitForExistence(timeout: 5))

        // The first button in the navigation bar of a pushed screen is always the back button.
        app.navigationBars["Dog"].buttons.firstMatch.tap()

        // Dog's grid card must be visible again to confirm we returned successfully.
        XCTAssertTrue(
            app.staticTexts["Dog"].waitForExistence(timeout: 5),
            "Did not return to the grid after tapping the back button"
        )
    }
}
