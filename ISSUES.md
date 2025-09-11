# Current Issues and Action Items

*Based on comprehensive code review and test results (90/98 tests passing)*

## 🚨 Critical Issues (Fix Immediately)

### Test Infrastructure Issues
- [ ] **Fix CellX constructor usage in tests** (`test_cellx.jl`)
  - **Error**: `MethodError: no method matching CellX(::Int64, ::Int64, ::String)`
  - **Root Cause**: Tests use old constructor signature, should use `cellx()` function
  - **Files**: `test_cellx.jl`, `test_hlinex.jl`, `test_vlinex.jl`, `test_tablex.jl`
  - **Impact**: 6 test errors blocking validation

- [ ] **Fix ParseError in test_hlinex.jl:28**
  - **Error**: `ParseError` at line 28, character 43
  - **Impact**: Prevents test suite completion
  - **Priority**: High - blocking test validation

### API Issues Identified by Tests
- [ ] **Method signature mismatch for figure_export**
  - **Test Failure**: `hasmethod(figure_export, (String, Any, Any))` returns false
  - **Root Cause**: Actual signature differs from test assumption
  - **Fix**: Check actual signature and update test or fix method

## ⚠️ API Design Issues (Breaking Changes)

### Constructor API Inconsistency
- [ ] **CellX constructor signature confusion**
  - **Issue**: Tests expect `CellX(x, y, content)` but actual is `CellX(content, x, y, ...)`
  - **Solution**: Decide on canonical constructor pattern
  - **Recommendation**: Use `cellx()` function consistently, document struct constructor

### Function Naming Inconsistency
- [ ] **Standardize regression table functions**
  - **Current**: Both `regtablet` and `regtable_typ` exist (duplicate functionality)
  - **File**: `src/regtable_copy.jl` vs `src/regtable.jl`
  - **Decision needed**: Which function to keep as primary API?
  
- [ ] **Missing key exports from main module**
  - **Status**: ✅ Partially fixed (recent exports added)
  - **Still missing**: Some internal functions that tests expect

## 🐛 Code Quality Issues

### Utilities Bug (Already Tracked)
- [ ] **Fix recursive digits parameter in utilities.jl:51-53**
  - **Status**: Tests show this may not be causing runtime errors as expected
  - **Action**: Verify if bug exists, fix if needed
  - **Current**: `function round(x::Tuple{Float64, Float64}; digits = digits)`
  - **Should be**: `function round(x::Tuple{Float64, Float64}; digits = 3)`

### Error Handling
- [ ] **Improve error messages throughout codebase**
  - **Examples**: "p-value key is wrong", "invalid format", "invalid fit specification"
  - **Goal**: Provide specific guidance on how to fix errors
  - **Files**: `src/regtable.jl`, `src/figure.jl`, `src/image.jl`

## 🔧 Test Suite Fixes (Non-Breaking)

### Fix Test API Usage
- [ ] **Update all CellX usage in tests to use cellx() function**
  - `test_cellx.jl` lines 47, 64, 84, 100, 115
  - `test_hlinex.jl` references to CellX constructor
  - `test_vlinex.jl` references to CellX constructor  
  - `test_tablex.jl` references to CellX constructor

- [ ] **Fix HLineX and VLineX constructor usage**
  - Similar pattern to CellX - use constructor functions instead of direct struct creation
  - Update test expectations to match actual API

- [ ] **Verify method signatures in export tests**
  - Check actual `figure_export` signature
  - Update test assertions to match reality
  - Consider if API should change or just tests

## 📚 Documentation Updates

### API Documentation
- [ ] **Document constructor patterns clearly**
  - When to use `CellX()` vs `cellx()`
  - Parameter order and types for all constructors
  - Examples of correct usage

- [ ] **Update README examples**
  - **Current status**: README acknowledges examples are "out of date and not correct"
  - **Action**: Update to match current API after fixes

### Code Documentation  
- [ ] **Add module-level docstrings**
  - Explain purpose of each source file
  - Document main functions and their usage
  - Add examples for complex functions

## 🗂️ Code Organization

### File Management
- [ ] **Resolve duplicate regtable files**
  - **Decision needed**: Keep `regtable.jl` or `regtable_copy.jl`?
  - **Current**: Both export different function names
  - **Recommendation**: Consolidate to avoid confusion

- [ ] **Review global variable usage**
  - `global typst_version = "\"@preview/tablex:0.0.9\""`
  - Consider making this a constant or parameter

## ✅ Recent Improvements (Completed)

- [x] **Test infrastructure setup** - Comprehensive test suite with 98 tests
- [x] **Documentation framework** - Documenter.jl with full structure
- [x] **GitHub Actions** - Automated CI/CD pipeline
- [x] **Package exports** - Major functions now exported
- [x] **Version bump** - Updated to 0.2.0

## 📊 Success Metrics

- **Current**: 90/98 tests passing (92% success)
- **Target**: 95/98 tests passing (97% success) 
- **Blocked by**: CellX constructor API issues (6 errors)
- **Next milestone**: Fix test API usage to validate core functionality

## 🎯 Priority Recommendations

1. **Week 1**: Fix test infrastructure (constructor usage, parse errors)
2. **Week 2**: Resolve API inconsistencies (regtable functions, exports)
3. **Week 3**: Improve error messages and documentation
4. **Week 4**: Code organization cleanup (duplicates, globals)

The package core is solid (90% test success) - remaining issues are primarily API consistency and test maintenance.