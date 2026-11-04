# NOTES

## Level 1 — constructors touched for `total`
Adding `total` to the badge touched 2 constructors: `BooksScreen` and `CartBadge`,
across 3 files: `main.dart`, `books_screen.dart`, `cart_badge.dart`.
Every widget between the owner and the badge had to carry a parameter it does not use itself.

## Level 1 — rebuild count
One tap on "Add" printed 7 lines: 1 x `BooksScreen build` + 6 x `row ...`.
`setState` in `Shell` marked the whole subtree dirty.

## Level 3 — provider errors
- Loud (`context.watch` inside `onPressed`):
  "Tried to listen to a value exposed with provider, from outside of the widget tree.
  This is likely caused by an event handler (like a button's onPressed) that called
  Provider.of without passing `listen: false`.
  To fix, write: Provider.of<Cart>(context, listen: false);"
- Silent (`context.read` inside the badge's `build`):No error and no warning. The badge stays frozen at 0, because nobody subscribed to the cart.

## Level 4 — badge rebuilds (3 presses of + in the cart)
- with `watch`: 3 x `badge build`
- with `select`: 0 x `badge build`

## Where does it live?
- The cart — provided. Two routes read and change it, so it sits above MaterialApp in ChangeNotifierProvider.
- The search text — lifted. The field (AppBar) and the list (body) are siblings, so it lives in their nearest common parent.
- Total expanded/collapsed — ephemeral. Only the total line cares, so it is a field of its own StatefulWidget.
- Theme mode — provided. MaterialApp needs it and the switch is elsewhere, so it lives above MaterialApp.