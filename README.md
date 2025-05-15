# Solitaire2---Parker-Lanum
5/14/2025

When I first started the first solitaire project, I thought it was spelled tableu, as is visible on that project's README. During the making of Solitaire 2, I thought it was spelled tablaeu, and this is visible constantly throughout the code. I am now aware that it is spelled tableau, and I will likely be painfully conscious of this fact for the rest of my life. 

I should note immediately that I was unable to to have the player move stacks of cards.

Programming patterns that appear in my code include: 
Prototyping for my implementation of cards through CardClass, 
States for storing a card's grab state as well as its position within the context of Solitaire,
Game Loop, as is implicit by the way Love2D handles its load, update, and draw functions.

Unfortunately, I was only able to have my code reviewed by Phineas Asmelash, a partner from our sections.

I made a couple of great changes to clean up my code since my first submission:
I rewrote my love.draw() function with the several recommendations I recieved during our in-class code review,
I defined multiple coordinates and color values that previously existed as vague numbers throughout code (see tablaeuCoords, foundationCoords, and my color tables)
I provided many comments to outline the functionality of individual code blocks so that code is much more readable,
I added another card state to track the location of each card relative to the context of Solitaire.

Regrettably, I did not proceed with implementation of cards pointing to one another or tableau tables that could store cards' relationships to one another despite my promises in the README of the first project. This likely would have been a big help for revealing cards that were suddenly at the bottom of a tableau, but I was mainly focused on reaching the new requirements in functionality.

All of the sprites were made by myself using the online tool, Piskel.

One serious struggle I faced with this project that I fear will be a problem for me in the future was the clash between the assignment's intent and the way it is actually graded. Although I was initially excited for this project and committed to the mission of refactoring all of my code with the various programming patterns we learned of in class, I was ultimately still working towards new functionality. Despite being part of the assignment, the rubric for improvements on code quality were limited and vague, while the requirements for implementation were extremely significant and clear in comparison. As a result, nearly all of my time on this project was spent struggling with the new demands in functionality, and hardly any was spent refactoring and beautifying code: what I believed to be the intended focus. In the end, I finished a far more functional version of the game Solitaire, but I am only slightly more satisfied with my code than I was before. 
