import 'package:flutter/material.dart' show BuildContext, debugPrint;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/user_profile.dart';
import '../providers/wallet_provider.dart';

class PdfExportService {
  /// Generates a real, professional PDF financial statement and opens native print/save dialog
  static Future<void> generateAndPrintStatement({
    required BuildContext context,
    required UserProfile? user,
    required WalletProvider wallet,
  }) async {
    try {
      final doc = pw.Document();
      final dateStr = DateFormat('dd MMMM yyyy, hh:mm a').format(DateTime.now());
      final transactions = wallet.transactions;
      final accounts = wallet.accounts;

      final userName = user?.displayName.isNotEmpty == true
          ? user!.displayName
          : (user?.isGuest == true ? 'Guest Explorer' : 'Account Holder');
      final userEmail = user?.email.isNotEmpty == true
          ? user!.email
          : (user?.isGuest == true ? 'guest@zerowallet.app' : 'Personal Finance Ledger');

      doc.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(36),
          header: (pw.Context ctx) => _buildHeader(userName, userEmail, dateStr),
          footer: (pw.Context ctx) => _buildFooter(ctx),
          build: (pw.Context ctx) => [
            pw.SizedBox(height: 16),
            _buildExecutiveSummary(wallet),
            pw.SizedBox(height: 20),
            _buildAccountsSection(accounts),
            pw.SizedBox(height: 20),
            _buildTransactionTable(transactions, wallet),
          ],
        ),
      );

      final fileName = 'Wallet_Statement_${DateFormat("yyyyMMdd").format(DateTime.now())}.pdf';

      await Printing.layoutPdf(
        name: fileName,
        onLayout: (PdfPageFormat format) async => doc.save(),
      );
    } catch (e) {
      debugPrint('[PdfExportService] Error generating PDF: $e');
    }
  }

  static pw.Widget _buildHeader(String name, String email, String dateStr) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 14),
      decoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300, width: 1.5)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'WALLET STATEMENT',
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColor.fromHex('#1E293B'),
                ),
              ),
              pw.SizedBox(height: 3),
              pw.Text(
                'Personal Financial Ledger & Telemetry',
                style: pw.TextStyle(
                  fontSize: 10,
                  color: PdfColor.fromHex('#64748B'),
                ),
              ),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                name,
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColor.fromHex('#0F172A'),
                ),
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                email,
                style: pw.TextStyle(
                  fontSize: 10,
                  color: PdfColor.fromHex('#64748B'),
                ),
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                'Generated: $dateStr',
                style: pw.TextStyle(
                  fontSize: 9,
                  color: PdfColor.fromHex('#94A3B8'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildExecutiveSummary(WalletProvider wallet) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(14),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex('#F8FAFC'),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
        border: pw.Border.all(color: PdfColor.fromHex('#E2E8F0')),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
        children: [
          _summaryItem('Net Worth', 'INR ${wallet.totalNetWorth.toStringAsFixed(0)}', PdfColor.fromHex('#0F172A')),
          _summaryItem('Total Income', '+INR ${wallet.totalIncome.toStringAsFixed(0)}', PdfColor.fromHex('#059669')),
          _summaryItem('Total Expense', '-INR ${wallet.totalExpense.toStringAsFixed(0)}', PdfColor.fromHex('#DC2626')),
          _summaryItem('Monthly Cap', 'INR ${wallet.monthlyBudget.toStringAsFixed(0)}', PdfColor.fromHex('#2563EB')),
        ],
      ),
    );
  }

  static pw.Widget _summaryItem(String label, String value, PdfColor valueColor) {
    return pw.Column(
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            fontSize: 9.5,
            color: PdfColor.fromHex('#64748B'),
            fontWeight: pw.FontWeight.normal,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 13,
            fontWeight: pw.FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildAccountsSection(List accounts) {
    if (accounts.isEmpty) return pw.SizedBox();

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Active Accounts Breakdown',
          style: pw.TextStyle(
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
            color: PdfColor.fromHex('#334155'),
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Wrap(
          spacing: 10,
          runSpacing: 6,
          children: accounts.map((acc) {
            return pw.Container(
              padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: pw.BoxDecoration(
                color: PdfColor.fromHex('#FFFFFF'),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                border: pw.Border.all(color: PdfColor.fromHex('#CBD5E1')),
              ),
              child: pw.Text(
                '${acc.name}: INR ${acc.balance.toStringAsFixed(0)}',
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColor.fromHex('#1E293B'),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  static pw.Widget _buildTransactionTable(List transactions, WalletProvider wallet) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Itemized Transactions (${transactions.length})',
          style: pw.TextStyle(
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
            color: PdfColor.fromHex('#334155'),
          ),
        ),
        pw.SizedBox(height: 8),
        if (transactions.isEmpty)
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            alignment: pw.Alignment.center,
            child: pw.Text(
              'No recorded transactions found in this ledger.',
              style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
            ),
          )
        else
          pw.TableHelper.fromTextArray(
            headers: ['#', 'Date', 'Title', 'Category', 'Account', 'Type', 'Amount (INR)'],
            headerStyle: pw.TextStyle(
              fontSize: 9,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
            ),
            headerDecoration: pw.BoxDecoration(
              color: PdfColor.fromHex('#1E293B'),
            ),
            headerHeight: 22,
            cellHeight: 20,
            cellStyle: const pw.TextStyle(fontSize: 8.5),
            cellAlignment: pw.Alignment.centerLeft,
            cellAlignments: {
              0: pw.Alignment.center,
              1: pw.Alignment.centerLeft,
              2: pw.Alignment.centerLeft,
              3: pw.Alignment.centerLeft,
              4: pw.Alignment.centerLeft,
              5: pw.Alignment.center,
              6: pw.Alignment.centerRight,
            },
            data: List<List<String>>.generate(transactions.length, (i) {
              final tx = transactions[i];
              final date = DateFormat('yyyy-MM-dd').format(tx.date);
              final acc = tx.accountId != null
                  ? wallet.accounts.firstWhere((a) => a.id == tx.accountId, orElse: () => wallet.accounts.first).name
                  : 'General';
              final sign = tx.type.name == 'income' ? '+' : '-';
              return [
                '${i + 1}',
                date,
                tx.title,
                tx.category,
                acc,
                tx.type.name.toUpperCase(),
                '$sign${tx.amount.toStringAsFixed(2)}',
              ];
            }),
          ),
      ],
    );
  }

  static pw.Widget _buildFooter(pw.Context ctx) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(top: 10),
      decoration: const pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: PdfColors.grey300, width: 0.8)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'Official Wallet Ledger Statement • End of Document',
            style: pw.TextStyle(fontSize: 8, color: PdfColors.grey500),
          ),
          pw.Text(
            'Page ${ctx.pageNumber} of ${ctx.pagesCount}',
            style: pw.TextStyle(fontSize: 8, color: PdfColors.grey600, fontWeight: pw.FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
