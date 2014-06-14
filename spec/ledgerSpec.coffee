L = require('ledger')

describe 'Ledger', ->

    it 'can add a purchase', ->
        ledger = new L.Ledger('test_ledger')
        res = ledger.put 'add_purchase', {creditor:'bob', amount:10, debtors:['alice', 'john', 'bob'], description:'bar'}
        expect(res.retcode).toBe 'ok'
        expect(ledger.total_cost).toBe 10

    it 'can change a purchase', ->
        ledger = new L.Ledger('test_ledger')
        res = ledger.put 'add_purchase', {creditor:'bob', amount:10, debtors:['alice', 'john', 'bob'], description:'bar'}
        id = res.id
        res = ledger.put 'chg_purchase', {creditor:'john', amount:20, debtors:['alice', 'john', 'mike'], description:'bars', id:id}
        expect(res.retcode).toBe 'ok'
        expect(ledger.total_cost).toBe 20
        expect(ledger.purchases[id].creditor).toBe 'john'
        expect(ledger.purchases[id].amount).toBe 20
        expect(ledger.purchases[id].description).toBe 'bars'
        expect(ledger.purchases[id].debtors).toEqual ['alice', 'john', 'mike']

    it 'can delete a purchase', ->
        ledger = new L.Ledger('test_ledger')
        res = ledger.put 'add_purchase', {creditor:'bob', amount:10, debtors:['alice', 'john', 'bob'], description:'bar'}
        id = res.id
        res = ledger.put 'del_purchase', {id:id}
        expect(res.retcode).toBe 'ok'
        expect(ledger.total_cost).toBe 0
        expect(ledger.purchases[id]).toBe undefined

    it 'can do a simple squash', ->
        ledger = new L.Ledger('test_ledger')
        res = ledger.put 'add_purchase', {creditor:'bob', amount:10, debtors:['alice', 'john', 'bob'], description:'bar'}
        id = res.id
        res = ledger.put 'del_purchase', {id:id}
        expect(res.retcode).toBe 'ok'
        ledger.squash()
        expect(ledger.ops.length).toBe 0

    it 'can add several purchases', ->
        ledger = new L.Ledger('test_ledger')
        res1 = ledger.put 'add_purchase', {creditor:'bob', amount:10, debtors:['alice', 'john', 'bob'], description:'foo'}
        expect(res1.retcode).toBe 'ok'
        res2 = ledger.put 'add_purchase', {creditor:'bob', amount:20, debtors:['alice', 'john', 'bob'], description:'bar'}
        expect(res2.retcode).toBe 'ok'
        res3 = ledger.put 'add_purchase', {creditor:'bob', amount:30, debtors:['alice', 'john', 'bob'], description:'foobar'}
        expect(res3.retcode).toBe 'ok'
        res4 = ledger.put 'add_purchase', {creditor:'bob', amount:40, debtors:['alice', 'john', 'bob'], description:'barfoo'}
        expect(res4.retcode).toBe 'ok'
        expect(ledger.total_cost).toBe 100

    it 'can add several purchases and change one', ->
        ledger = new L.Ledger('test_ledger')
        res1 = ledger.put 'add_purchase', {creditor:'bob', amount:10, debtors:['alice', 'john', 'bob'], description:'foo'}
        expect(res1.retcode).toBe 'ok'
        res2 = ledger.put 'add_purchase', {creditor:'bob', amount:20, debtors:['alice', 'john', 'bob'], description:'bar'}
        expect(res2.retcode).toBe 'ok'
        res3 = ledger.put 'add_purchase', {creditor:'bob', amount:30, debtors:['alice', 'john', 'bob'], description:'foobar'}
        expect(res3.retcode).toBe 'ok'
        res4 = ledger.put 'add_purchase', {creditor:'bob', amount:40, debtors:['alice', 'john', 'bob'], description:'barfoo'}
        expect(res4.retcode).toBe 'ok'
        res5 = ledger.put 'chg_purchase', {id:res4.id, creditor:'bob', amount:10, debtors:['alice', 'john', 'bob'], description:'barfoo'}
        expect(res5.retcode).toBe 'ok'
        expect(ledger.total_cost).toBe 70

    it 'refuses to add purchase with missing creditor', ->
        ledger = new L.Ledger('test_ledger')
        expect(-> ledger.put('add_purchase', {amount:0, debtors:['alice', 'john', 'bob'], description:'foo'})).toThrow 'no creditor'

    it 'refuses to add purchase with zero length creditor', ->
        ledger = new L.Ledger('test_ledger')
        expect(-> ledger.put('add_purchase', {creditor: '', amount:0, debtors:['alice', 'john', 'bob'], description:'foo'})).toThrow 'zero length creditor'

    it 'refuses to add purchase with missing amount', ->
        ledger = new L.Ledger('test_ledger')
        expect(-> ledger.put('add_purchase', {creditor:'bob', debtors:['alice', 'john', 'bob'], description:'foo'})).toThrow 'no amount'

    it 'refuses to add purchase with zero amount', ->
        ledger = new L.Ledger('test_ledger')
        expect(-> ledger.put('add_purchase', {creditor:'bob', amount:0, debtors:['alice', 'john', 'bob'], description:'foo'})).toThrow 'non positive amount'

    it 'refuses to add purchase with negative amount', ->
        ledger = new L.Ledger('test_ledger')
        expect(-> ledger.put('add_purchase', {creditor:'bob', amount:-10, debtors:['alice', 'john', 'bob'], description:'foo'})).toThrow 'non positive amount'

    it 'refuses to add purchase with missing debtors', ->
        ledger = new L.Ledger('test_ledger')
        expect(-> ledger.put('add_purchase', {creditor:'bob', amount:10, description:'foo'})).toThrow 'no debtors'

    it 'refuses to add purchase with empty debtors', ->
        ledger = new L.Ledger('test_ledger')
        expect(-> ledger.put('add_purchase', {creditor:'bob', amount:10, debtors:[], description:'foo'})).toThrow 'no debtors'

    it 'refuses to add purchase with zero length debtors', ->
        ledger = new L.Ledger('test_ledger')
        expect(-> ledger.put('add_purchase', {creditor:'bob', amount:10, debtors:['alice', 'bob', ''], description:'foo'})).toThrow 'some debtors are zero length'

    it 'refuses to add purchase with missing description', ->
        ledger = new L.Ledger('test_ledger')
        expect(-> ledger.put('add_purchase', {creditor:'bob', amount:10, debtors:['alice', 'bob']})).toThrow 'no description'

    it 'refuses to add purchase with zero length description', ->
        ledger = new L.Ledger('test_ledger')
        expect(-> ledger.put('add_purchase', {creditor:'bob', amount:10, debtors:['alice', 'bob'], description:''})).toThrow 'zero length description'

    it 'refuses to change missing purchase', ->
        ledger = new L.Ledger('test_ledger')
        expect(-> ledger.put('chg_purchase', {id:'foo', creditor:'bob', amount:10, debtors:['alice', 'bob'], description:'bar'})).toThrow 'unknown purchase'

    it 'refuses to delete missing purchase', ->
        ledger = new L.Ledger('test_ledger')
        expect(-> ledger.put('del_purchase', {id:'foo', creditor:'bob', amount:10, debtors:['alice', 'bob'], description:'bar'})).toThrow 'unknown purchase'

    it 'can handle stray id field when adding purchase', ->
        ledger = new L.Ledger('test_ledger')
        res = ledger.put 'add_purchase', {id:'foo', creditor:'bob', amount:10, debtors:['alice', 'bob'], description:'bar'}
        expect(res.id).not.toBe 'foo'
