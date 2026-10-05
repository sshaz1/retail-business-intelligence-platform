## Data Quality Notes

### Credit Card Installment Anomaly

During payment analysis, two credit card payment records were identified with a `payment_installments` value of `0`.

A credit card installment count would normally be expected to be at least `1`, making these records anomalous.

```text
order_id                          payment_sequential    payment_installments    payment_value
744bade1fcf9ff3f31d860ace076d422  2                     0                       58.69
1a57108394169c0b47d8f876acc9ba2d  2                     0                       129.94
```

Both records also have `payment_sequential = 2`. Further inspection found no corresponding `payment_sequential = 1` records for either order in the payments dataset.

### Handling

The records were retained because their payment values may still represent valid transactions and there is not enough information to reliably correct the source data.

For analyses involving credit card installment behaviour, records where `payment_installments <= 0` are excluded.

```sql
WHERE payment_type = 'credit_card'
    AND payment_installments > 0
```

This prevents anomalous installment values from affecting installment-related analysis while preserving the original payment records for other analyses.